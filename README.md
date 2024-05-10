# ECG Classification Accelerator

## Workflow

1. Algorithm
   1. Data
   2. Model
   3. Evaluation 
   4. Quantization
   5. Evaluation again 
   6. Fixed-point conversion
   7. Evaluation again
2. Hardware
   1. Submodule 
      1. 
      2. 16*16 Systolic Array 

## Model

### Data

- Signal Length: First 15 samples
- Data: [ECG Heartbeat Classification: A Deep Transferable Representation](https://arxiv.org/abs/1805.00794)

| Label | Output |
| ----- | ------ |
| N     | 0      |
| S     | 1      |
| V     | 2      |
| F     | 3      |
| Q     | 4      |
| MI    | 5      |

### Visualization

#### Netron Jit traced

![traced_resnet_model.pth](https://raw.githubusercontent.com/frankxaio/markdwon-image/main/data/traced_resnet_model.pth.svg)



#### Netron pth ​convert to​ ONNX 

![model.onnx](https://raw.githubusercontent.com/frankxaio/markdwon-image/main/data/model.onnx.svg)

### Torchinfo Summary

*ignore dropout*

```text
Model Summary for ECGformer:
====================================================================================================
Layer (type:depth-idx)                             Input Shape               Output Shape
====================================================================================================
ECGformer                                          [1, 15, 1]                [1, 6]
├─LinearEmbedding: 1-1                             [1, 15, 1]                [1, 16, 16]
│    └─Linear: 2-1                                 [1, 15, 1]                [1, 15, 16]
│    └─ReLU: 2-2                                   [1, 15, 16]               [1, 15, 16]
├─ModuleList: 1-2                                  --                        --
│    └─TransformerEncoderLayer: 2-3                [1, 16, 16]               [1, 16, 16]
│    │    └─ResidualAdd: 3-1                       [1, 16, 16]               [1, 16, 16]
│    │    │    └─Sequential: 4-1                   [1, 16, 16]               [1, 16, 16]
│    │    │    │    └─MultiHeadAttention: 5-1      [1, 16, 16]               [1, 16, 16]
│    │    │    │    │    └─Linear: 6-1             [1, 16, 16]               [1, 16, 16]  
│    │    │    │    │    └─Linear: 6-2             [1, 16, 16]               [1, 16, 16]
│    │    │    │    │    └─Linear: 6-3             [1, 16, 16]               [1, 16, 16]
│    │    │    │    │    └─Linear: 6-4             [1, 16, 16]               [1, 16, 16]
│    │    └─ResidualAdd: 3-2                       [1, 16, 16]               [1, 16, 16]
│    │    │    └─Sequential: 4-2                   [1, 16, 16]               [1, 16, 16]
│    │    │    │    └─MLP: 5-3                     [1, 16, 16]               [1, 16, 16]
│    │    │    │    │    └─Linear: 6-5             [1, 16, 16]               [1, 16, 16]
│    │    │    │    │    └─ReLU: 6-6               [1, 16, 16]               [1, 16, 16]
│    │    │    │    │    └─Linear: 6-7             [1, 16, 16]               [1, 16, 16]
├─Classifier: 1-3                                  [1, 16, 16]               [1, 6]
│    └─Reduce: 2-4                                 [1, 16, 16]               [1, 16]
│    └─Linear: 2-5                                 [1, 16]                   [1, 6]
====================================================================================================
```

### Fixed Point 

| Layer/Parameter       | Bit Width | Integer Part | Fraction Part |
| --------------------- | --------- | ------------ | ------------- |
| `Linear: Scale`       | 16-bit    | 1-bit        | 15-bit        |
| `Linear: Bias`        | 16-bit    | 1-bit        | 15-bit        |
| `Linear: Weight`      | 8-bit     | 8-bit        | 0-bit         |
| `cls_token`           | 16-bit    | 4-bit        | 12-bit        |
| `positional_encoding` | 16-bit    | 4-bit        | 12-bit        |

## Hardware

> [!NOTE]
> $$
> \text{Linear}: y = xA^{T}+b
> $$
> 使用 MAC 進行矩陣乘法，最後再加上 b
> $$
> \mathrm{ReLU}(x) = (x)^+ = \max(0, x)
> $$
> 使用比較器和MUX，若小於零則都給零，若大於零則選擇自己。
> $$
> Attention(Q, K, V) = \mathrm{softmax}\left(\frac{QK^T}{\sqrt{d_k}}\right)V
> $$
> 使用 Systolic 進行併行的矩陣乘法
> $$
> A = \begin{bmatrix}
> q_{1,1} & q_{1,2} & \cdots & q_{1,16} \\
> q_{2,1} & q_{2,2} & \cdots & q_{2,16} \\
> \vdots  & \vdots  & \ddots & \vdots   \\
> q_{16,1} & q_{16,2} & \cdots & q_{16,16} \\
> \end{bmatrix} \\  \\
> \text{Reduce} (A) = \begin{bmatrix}\sum_{r=1}^{16}(q_{r,1})& \sum_{r=1}^{16}(q_{r,2}) &\cdots & \sum_{r=1}^{16}(q_{16,1}) \end{bmatrix}
> $$
> 

### Linear Embedding

- MMU: $\text{size}(15,1)\times \text{size}(16,1)^T + bias=\text{size}(15,16)$ 

- Concatenation: $\{\text{size}(15,16), \text{size}(1, 16)\}=\text{size}(16,16)$ 
  $$
  \begin{bmatrix}
  a_{1,1} & a_{1,2} & \cdots & a_{1,15} \\
  a_{2,1} & a_{2,2} & \cdots & a_{2,15} \\
  \vdots  & \vdots  & \ddots & \vdots   \\
  a_{16,1} & a_{16,2} & \cdots & a_{16,15}
  \end{bmatrix}
  +
  \begin{bmatrix}
  b_{1,1} & b_{1,2} & \cdots & b_{1,16}
  \end{bmatrix}
  =
  \begin{bmatrix}
  a_{1,1} & a_{1,2} & \cdots & a_{1,15} \\
  a_{2,1} & a_{2,2} & \cdots & a_{2,15} \\
  \vdots  & \vdots  & \ddots & \vdots   \\
  a_{16,1} & a_{16,2} & \cdots & a_{16,15} \\
  b_{1,1} & b_{1,2} & \cdots & b_{1,16}
  \end{bmatrix}
  $$
  

### Attention

16*16 Systolic MMU use 8 times: $\text{size}(16,16) \times \text{size}(16,16)^T + bias$

1. Q projection
2. K projection 
3. V projection
4. Calculate $Q\times K^T$
5. Calculate $(Q\times K^T)V$
6. Final projection
7. MLP projection

### Classifier




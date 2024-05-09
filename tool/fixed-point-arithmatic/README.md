# Fixed-point Arithmatic

8-bit fixed-point 乘法測試，2-bit 整數部分，6-bit 分數部分。a, b 是 `8-bit` 有號數，輸出是 `31-bit` `prod_ab` 。`8-bit` `prob_ab_slc` 取 `prob_ab` 中間的 8-bit，也就是中間剛好湊一組 2-bit 整數，6-bit 分數的部分。

輸入

```
        a   = 8'b1110_1100;  // -0.3125
        b   = 8'b0001_0110;  // 0.34375
```

輸出

![image-20240510001601903](https://raw.githubusercontent.com/frankxaio/markdwon-image/main/data/image-20240510001601903.png)


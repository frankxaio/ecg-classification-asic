% 定義x的取值範圍
x = -5:0.01:5;

% 計算ReLU函數值
y1 = max(0, x);

% 計算GELU函數值
y2 = 0.5 .* x .* (1 + erf(x / sqrt(2)));

% 繪製ReLU和GELU函數圖形
figure;
plot(x, y1, 'r', 'LineWidth', 2);
hold on;
plot(x, y2, 'b', 'LineWidth', 2);
xlabel('x');
ylabel('y');
title('ReLU and GELU Functions');
legend('ReLU', 'GELU', 'Location', 'NorthWest');
grid on;

diff = y1 - y2;

% 繪製差值圖形
figure;
plot(x, diff, 'LineWidth', 2);
xlabel('x');
ylabel('ReLU(x) - GELU(x)');
title('Difference between ReLU and GELU');
grid on;

% 找出差值的最大值及其對應的x值
[max_diff, max_idx] = max(abs(diff));
x_max = x(max_idx);

fprintf('最大差值為: %.4f\n', max_diff);
fprintf('最大差值對應的x值為: %.2f\n', x_max);

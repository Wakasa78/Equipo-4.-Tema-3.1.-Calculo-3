clc; clear; close all;

%% Datos del problema
f = @(x,y) x.^2/8 + y.^2/4;   % fondo del tanque
a = 4; b = 2; H = 3;          % base y nivel final

%% 1) Valor exacto y valor numérico
V_exacto = 16;
V_num = integral2(@(x,y) H - f(x,y), 0, a, 0, b);
fprintf('Exacto: %.4f m^3 | integral2: %.4f m^3\n', V_exacto, V_num);

%% 2) Sumas de Riemann (punto medio)
n = [2 4 8 16 32];
Vr = zeros(size(n));
for i = 1:numel(n)
    dx = a/n(i); dy = b/n(i);
    xm = dx/2 : dx : a;
    ym = dy/2 : dy : b;
    [XM, YM] = meshgrid(xm, ym);
    Vr(i) = sum(sum(H - f(XM, YM))) * dx * dy;
    fprintf('n = %2d  ->  V = %.5f m^3\n', n(i), Vr(i));
end

%% 3) Animación del llenado
[X, Y] = meshgrid(linspace(0,a,70), linspace(0,b,40));
Z = f(X, Y);
niveles = linspace(0, H, 60);
Vn = zeros(size(niveles));

fig = figure('Color','w','Position',[100 100 1100 450]);
v = VideoWriter('llenado_tanque.mp4','MPEG-4'); open(v);

for k = 1:numel(niveles)
    L = niveles(k);
    Vn(k) = integral2(@(x,y) max(L - f(x,y), 0), 0, a, 0, b);

    % Gráfica 3D
    subplot(1,2,1); cla;
    surf(X, Y, Z, 'FaceColor',[0.6 0.4 0.2], 'EdgeColor','none'); hold on;
    W = L*ones(size(Z)); W(Z >= L) = NaN;       % agua solo donde hay profundidad
    surf(X, Y, W, 'FaceColor',[0.2 0.5 1], 'FaceAlpha',0.6, 'EdgeColor','none');
    axis([0 a 0 b 0 H]); view(-35, 25); camlight; grid on;
    xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
    title(sprintf('Nivel del agua: %.2f m', L));

    % Curva V(nivel)
    subplot(1,2,2); cla;
    plot(niveles(1:k), Vn(1:k), 'b-', 'LineWidth', 2); hold on;
    plot(L, Vn(k), 'ro', 'MarkerFaceColor','r');
    xlim([0 H]); ylim([0 V_exacto]); grid on;
    xlabel('Nivel (m)'); ylabel('Volumen (m^3)');
    title(sprintf('V = %.2f m^3', Vn(k)));

    drawnow; writeVideo(v, getframe(fig));
end
close(v);
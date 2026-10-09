% design_filter.m : 실습 A-6  저역통과 FIR·IIR 필터를 설계하고 C 구현 결과와 비교
%
% 필요 : MATLAB + Signal Processing Toolbox (fir1, butter, freqz)
%        filter 함수는 MATLAB 기본 함수이다.
% 실행 : >> design_filter
%        Pi에서 만든 filter_out.csv(./filter_demo csv > filter_out.csv)를
%        이 파일과 같은 폴더에 두면, 같은 입력을 MATLAB으로 걸러 C 결과와 비교한다.
%
% 원본 : 「Matlab 백서」 Filter Design 코드를 고쳤다.
%        - if 문에서 정의되지 않은 변수 Type을 사용 → filterType 하나로 통일
%        - IIR인데 filter(b,1,x)로 거름(분모 a를 무시) → filter(b,a,x)
%        - butter(20,...)를 (b,a) 전달함수 형태로 사용 → 수치적으로 불안정하므로
%          2차를 쓰고, 고차가 필요하면 [z,p,k] → zp2sos → sosfilt 를 쓴다

fs = 100;                 % 샘플링 주파수 [Hz]
fc = 10;                  % 차단 주파수 [Hz]
Wn = fc / (fs/2);         % 나이퀴스트 주파수로 정규화한 차단 주파수 (0.2)
N  = 20;                  % FIR 차수 (계수 21개)
filterType = 'low';       % 'low' | 'high' (대역 필터는 Wn을 [f1 f2]/(fs/2)로)

%% 1) 설계
bFir = fir1(N, Wn, filterType);          % 해밍 창(기본값), DC 이득 1로 정규화
aFir = 1;
[bIir, aIir] = butter(2, Wn, filterType);% 2차 버터워스

printCoef('b_fir', bFir);                % filter_demo.c 출력과 같은 형식
printCoef('b_iir', bIir);
printCoef('a_iir', aIir);
fprintf('IIR 극점 크기: %s (모두 1보다 작아야 안정)\n', mat2str(abs(roots(aIir)).', 4));

%% 2) 주파수 응답 비교
[Hf, f] = freqz(bFir, aFir, 1024, fs);
Hi      = freqz(bIir, aIir, 1024, fs);
figure(1); clf;
subplot(2,1,1);
plot(f, 20*log10(abs(Hf)), f, 20*log10(abs(Hi)), '--'); grid on;
xlabel('주파수 [Hz]'); ylabel('크기 [dB]'); ylim([-80 5]);
legend('FIR 20차', 'IIR 2차 버터워스'); title('저역통과 필터 크기 응답');
subplot(2,1,2);
plot(f, unwrap(angle(Hf)), f, unwrap(angle(Hi)), '--'); grid on;
xlabel('주파수 [Hz]'); ylabel('위상 [rad]'); title('위상 응답 (FIR은 직선)');

%% 3) 시간 영역 시험: C 결과가 있으면 같은 입력으로 비교
if isfile('filter_out.csv')
    d = readmatrix('filter_out.csv');    % 열: n, t, x, y_fir, y_iir
    t = d(:,2);  x = d(:,3);
    yFirC = d(:,4);  yIirC = d(:,5);
    src = 'C(filter_demo)와 같은 입력';
else
    t = (0:199).' / fs;
    rng(0);                              % 재현 가능한 잡음
    x = sin(2*pi*5*t) + sin(2*pi*20*t) + sin(2*pi*30*t) + 0.2*(rand(size(t))-0.5);
    yFirC = [];  yIirC = [];
    src = 'MATLAB에서 만든 입력';
end
yFir = filter(bFir, aFir, x);
yIir = filter(bIir, aIir, x);            % IIR은 반드시 분모 a까지 넘긴다

if ~isempty(yFirC)
    fprintf('MATLAB과 C의 최대 차이: FIR %.2e, IIR %.2e\n', ...
            max(abs(yFir - yFirC)), max(abs(yIir - yIirC)));
end

figure(2); clf;
plot(t, x, 'Color', [0.7 0.7 0.7]); hold on;
plot(t, yFir, t, yIir, '--'); grid on;
if ~isempty(yFirC)
    plot(t(1:5:end), yFirC(1:5:end), 'o', t(1:5:end), yIirC(1:5:end), 'x');
    legend('입력', 'FIR (MATLAB)', 'IIR (MATLAB)', 'FIR (C)', 'IIR (C)');
else
    legend('입력', 'FIR (MATLAB)', 'IIR (MATLAB)');
end
xlabel('시간 [s]'); title(['5 Hz만 남기는 저역통과 필터 - ' src]);

%% 로컬 함수
function printCoef(name, c)
    c(abs(c) < 5e-7) = 0;                % -0.000000 표시 방지(C 쪽과 같게)
    fprintf('%s = [%s]\n', name, strtrim(sprintf('%.6f ', c)));
end

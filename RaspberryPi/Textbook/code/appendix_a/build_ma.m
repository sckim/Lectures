% build_ma.m : 실습 A-3  moving_average.m 을 MATLAB Coder로 C 소스 코드로 변환
%
% 필요 : MATLAB Coder 라이선스 (이 방법은 Raspberry Pi 지원 패키지 없이도 된다)
% 실행 : moving_average.m 이 있는 폴더에서 >> build_ma
% 결과 : codegen/lib/moving_average/ 에 .c/.h 파일과 보고서가 생긴다.
%        이 폴더를 Pi의 같은 위치(~/Textbook/code/appendix_a/)로 복사한 뒤
%        Pi에서 make ma 로 빌드한다.

%% 1) MATLAB에서 먼저 확인: 원래 filter와 결과가 같은가
x = sin(2*pi*1.2*(0:99)/100);           % 1.2 Hz, 100샘플
clear moving_average                    % persistent 상태 비우기
y1 = moving_average(x);
yref = filter(ones(1,5)/5, 1, x);
fprintf('MATLAB 확인: 최대 오차 = %g\n', max(abs(y1 - yref)));
clear moving_average                    % 확인용으로 바뀐 상태를 다시 비운다

%% 2) 코드 생성 설정
cfg = coder.config('lib');              % 라이브러리용 소스. main()은 우리가 쓴다
cfg.TargetLang     = 'C';
cfg.GenCodeOnly    = true;              % PC에서 컴파일하지 않고 소스만 만든다
cfg.GenerateReport = true;              % 코드 생성 보고서(HTML)
% 타깃 CPU 정보: Raspberry Pi 4 + 64비트 OS (int, long, 포인터 크기가 정해진다)
cfg.HardwareImplementation.ProdHWDeviceType = 'ARM Compatible->ARM Cortex-A (64-bit)';

%% 3) 코드 생성: 입력 x는 1x100 double 이라고 예시 값으로 알려 준다
codegen -config cfg moving_average -args {zeros(1,100)}

disp('생성된 파일:');
disp(ls(fullfile('codegen', 'lib', 'moving_average', '*.c')));

% manage_model.m : 실습 A-4  Pi에 배포한 Simulink 애플리케이션을 MATLAB에서 관리
%
% 필요 : Simulink용 Raspberry Pi 지원 패키지 (R2026a 이상은 Raspberry Pi Blockset)
% 실행 : 실습 A-4에서 Build, Deploy & Start를 한 번 한 뒤 >> manage_model
% 참고 : raspberrypi 객체는 배포·파일·프로세스 관리용이다(GPIO 함수는 raspi 객체).

modelName = 'gpio_blink';                       % 실습 A-4에서 만든 모델 이름
board = raspberrypi('192.168.0.xx', 'student', input('Pi 암호: ', 's'));

% 1) 지금 실행 중인가?
fprintf('%s 실행 중? %d\n', modelName, isModelRunning(board, modelName));

% 2) Pi에 저장된 실행 파일(.elf) 찾기: MATLAB_ws 아래 릴리스별 폴더에 있다
fprintf('%s', system(board, 'find ~/MATLAB_ws -name "*.elf" | head'));

% 3) 프로세스와 스케줄링 정책 보기 (FF = SCHED_FIFO)
fprintf('%s', system(board, ['ps -eo pid,cls,rtprio,pcpu,args | grep ' ...
                             modelName ' | grep -v grep']));

% 4) 멈추기와 다시 시작하기
stopModel(board, modelName);
fprintf('정지 후 실행 중? %d\n', isModelRunning(board, modelName));
runModel(board, modelName);
fprintf('재시작 후 실행 중? %d\n', isModelRunning(board, modelName));

% 부팅할 때 자동 실행: methods(board)에 보이는 addToRunOnBoot / removeRunOnBoot,
% 또는 Raspberry Pi Resource Monitor 앱을 쓴다(사용법은 help로 확인).

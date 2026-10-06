% connect_pi.m : 실습 A-1  MATLAB에서 Raspberry Pi에 연결하고 Linux 명령 실행
%
% 필요 : MATLAB + Raspberry Pi 지원 패키지
%        (R2026a 이상: Raspberry Pi Blockset,
%         R2025b 이하: MATLAB Support Package for Raspberry Pi Hardware)
% 실행 : >> connect_pi
% 주의 : IP와 사용자 이름은 자신의 Pi에 맞게 고친다. 암호는 파일에 적지 않는다.
%        변수 이름을 pi로 하지 않는다(MATLAB의 원주율 상수 pi를 가린다).

ipAddr   = '192.168.0.xx';               % Pi에서 hostname -I 로 확인한 주소
userName = 'student';                    % Raspberry Pi Imager에서 만든 사용자
passWord = input('Pi 암호: ', 's');      % 실행할 때 입력받는다

rpi = raspi(ipAddr, userName, passWord); % SSH로 접속해 하드웨어 연결 객체를 만든다
clear passWord
disp(rpi)                                % BoardName, AvailableDigitalPins 등 확인

% system(): Pi의 셸에서 명령을 실행하고 결과를 문자열로 돌려받는다
fprintf('%s', system(rpi, 'uname -a'));          % 커널 버전, 아키텍처(aarch64)
fprintf('%s', system(rpi, 'cat /etc/os-release | head -4'));
fprintf('%s', system(rpi, 'free -h'));           % 메모리
fprintf('%s', system(rpi, 'pinctrl get 17'));    % LED 핀 상태 (8장 8.8절)

% 다음 실습부터는 rpi = raspi(); 만으로 마지막 연결 정보를 다시 쓴다.
clear rpi                                % 연결 닫기

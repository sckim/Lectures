function led_blink(nBlink)
% led_blink : 실습 A-2  MATLAB에서 GPIO17 LED 깜빡이기 (호스트 제어 방식)
%   >> led_blink        5번 깜빡인다
%   >> led_blink(10)    10번 깜빡인다
%
% 회로 : GPIO17 (물리 핀 11) -> 330 Ω -> LED(애노드→캐소드) -> GND (물리 핀 9)
% 준비 : connect_pi.m 으로 한 번 연결에 성공해 두면 raspi()가 그 정보를 다시 쓴다.
%
% 원본 「Raspberry Pi Codes」 §10 예제를 고쳤다.
%   - raspberrypi 객체에 configurePin을 씀 → GPIO 함수는 raspi 객체에서 쓴다
%   - 변수 이름 pi → rpi (원주율 상수 pi를 가리지 않게)
%   - MATLAB에 없는 try/catch/finally 문법 → onCleanup으로 정리 보장

if nargin < 1
    nBlink = 5;
end
ledPin = 17;                                   % BCM 번호

rpi = raspi();                                 % 마지막으로 성공한 연결 재사용
configurePin(rpi, ledPin, 'DigitalOutput');

% 함수가 끝나거나 Ctrl+C로 멈춰도 LED를 끄도록 정리 작업을 예약한다
cleanupObj = onCleanup(@() ledOff(rpi, ledPin)); %#ok<NASGU>

for k = 1:nBlink
    writeDigitalPin(rpi, ledPin, 1);
    fprintf('LED ON  (%d/%d)\n', k, nBlink);
    pause(0.5);
    writeDigitalPin(rpi, ledPin, 0);
    fprintf('LED OFF (%d/%d)\n', k, nBlink);
    pause(0.5);
end
end

function ledOff(rpi, pin)
writeDigitalPin(rpi, pin, 0);
fprintf('LED를 끄고 종료\n');
end

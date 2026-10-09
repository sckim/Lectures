function button_read(durationSec)
% button_read : 실습 A-2  GPIO26 버튼을 읽어 GPIO17 LED에 반영 (호스트 제어 방식)
%   >> button_read       20초 동안 실행
%   >> button_read(5)    5초 동안 실행
%
% 회로 : GPIO26 (물리 핀 37) - 버튼 - GND (물리 핀 39), 내부 풀업 사용
%        GPIO17 (물리 핀 11) - 330 Ω - LED - GND      (8장 실습 8-3과 같다)
% 동작 : 풀업이므로 안 누르면 1, 누르면 0(active-low). LED는 그 반대로 켠다.
%        마지막에 한 번 읽는 데 걸린 평균 시간을 출력한다.

if nargin < 1
    durationSec = 20;
end
btnPin = 26;
ledPin = 17;

rpi = raspi();
configurePin(rpi, btnPin, 'DigitalInput');
configurePin(rpi, ledPin, 'DigitalOutput');
% configurePin에는 풀업 옵션이 없으므로 Pi의 pinctrl 명령으로 내부 풀업을 켠다
system(rpi, 'pinctrl set 26 ip pu');
cleanupObj = onCleanup(@() writeDigitalPin(rpi, ledPin, 0)); %#ok<NASGU>

fprintf('%d초 동안 버튼을 읽는다 (Ctrl+C로 중단)\n', durationSec);
prev  = -1;
nRead = 0;
t0 = tic;
while toc(t0) < durationSec
    level = readDigitalPin(rpi, btnPin);      % 1 = 안 누름, 0 = 누름
    nRead = nRead + 1;
    writeDigitalPin(rpi, ledPin, double(~level));
    if level ~= prev                           % 바뀔 때만 출력
        fprintf('%6.2f s  button=%d  LED=%d\n', toc(t0), level, ~level);
        prev = level;
    end
end
fprintf('읽기+쓰기 %d회, 1회 평균 %.1f ms (네트워크 왕복 포함)\n', ...
        nRead, 1000 * toc(t0) / nRead);
end

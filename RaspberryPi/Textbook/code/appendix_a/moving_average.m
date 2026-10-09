function y = moving_average(x) %#codegen
% moving_average : 실습 A-3  5점 이동 평균 필터 (C 코드 생성용)
%   y = moving_average(x)
%   x : 1x100 double, 한 번에 들어오는 신호 블록 (fs = 100 Hz이면 1초 분량)
%   y : 1x100 double, 필터 출력
%
% 블록을 여러 번 나누어 넣어도 필터가 끊기지 않도록, 앞 블록의 마지막
% 입력(필터 상태 zi)을 persistent 변수에 보관한다. persistent 변수는
% 생성된 C 코드에서 전역 상태가 되고, moving_average_initialize()가 초기화한다.
%
% 원본 「Matlab 백서」 예제는 블록마다 filter(b,a,x)를 새로 불러 블록 경계에서
% 필터가 0부터 다시 시작했다(경계마다 출력이 출렁인다). 이를 고쳤다.

windowSize = 5;
b = ones(1, windowSize) / windowSize;   % 계수 0.2가 5개
a = 1;                                  % FIR이므로 분모는 1

persistent zi
if isempty(zi)
    zi = zeros(windowSize - 1, 1);      % 처음 한 번만 0으로 (열 벡터)
end

[y, zi] = filter(b, a, x, zi);          % 상태를 넣고, 바뀐 상태를 돌려받는다
end

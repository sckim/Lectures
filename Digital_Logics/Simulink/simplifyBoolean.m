function [simplified_express] = simplifyBoolean(minterms, num_vars)
% SIMPLIFYBOOLEAN: 민텀을 퀸-매클러스키 알고리즘의 기초를 활용하여 간략화합니다.
%   minterms: 간략화할 민텀 번호들의 벡터 (예: [0, 2, 5, 7])
%   num_vars: 부울 변수의 개수 (예: 3)
%   simplified_terms: 간략화된 2진수 형태의 항 목록 (대시 '-'는 Don't Care를 의미)

    % 1. 민텀을 2진수로 변환하고 1의 개수(Index)에 따라 정렬합니다.
    bin_minterms = cell(1, num_vars + 1);
    
    for i = 1:length(minterms)
        % 숫자를 2진수 문자열로 변환 (num_vars 자릿수에 맞춰 앞을 0으로 채움)
        bin_str = dec2bin(minterms(i), num_vars);
        
        % 1의 개수를 셉니다. (이를 그룹 인덱스로 사용)
        ones_count = sum(bin_str == '1');
        
        % 해당 그룹 인덱스에 저장합니다.
        bin_minterms{ones_count + 1} = [bin_minterms{ones_count + 1}; {bin_str, false}];
        % {2진수 문자열, 간략화에 사용되었는지 여부 (false)}
    end

    % 2. 반복적인 비교 및 그룹화 단계 (1비트 차이 검사)
    implicants = bin_minterms;
    new_implicants = cell(1, num_vars + 1);
    prime_implicants = {};
    
    while true
        found_new = false;
        new_implicants(:) = {[]}; % 새로운 함축항 저장을 위해 초기화

        % 인접한 두 그룹을 비교합니다 (i번째 그룹과 i+1번째 그룹).
        for i = 1:num_vars
            current_group = implicants{i};
            next_group = implicants{i+1};
            
            if isempty(current_group) || isempty(next_group)
                continue;
            end
            
            % 현재 그룹과 다음 그룹의 모든 항을 비교합니다.
            for j = 1:size(current_group, 1)
                for k = 1:size(next_group, 1)
                    term1 = current_group{j, 1};
                    term2 = next_group{k, 1};
                    
                    % 1비트만 차이 나는지 확인합니다.
                    diff = 0;
                    diff_pos = 0;
                    for bit = 1:num_vars
                        if term1(bit) ~= term2(bit)
                            diff = diff + 1;
                            diff_pos = bit;
                        end
                    end
                    
                    if diff == 1
                        % 1비트만 차이나면 새로운 함축항을 만듭니다.
                        new_term = term1;
                        new_term(diff_pos) = '-'; % 차이나는 비트를 Don't Care로 표시
                        
                        % 새로운 함축항을 이미 찾았는지 확인하고 추가합니다.
                        is_new = true;
                        for l = 1:size(new_implicants{i}, 1)
                            if strcmp(new_implicants{i}{l, 1}, new_term)
                                is_new = false;
                                break;
                            end
                        end
                        
                        if is_new
                            new_implicants{i} = [new_implicants{i}; {new_term, false}];
                            found_new = true;
                        end
                        
                        % 비교에 사용된 항은 체크 표시를 합니다.
                        implicants{i}{j, 2} = true;
                        implicants{i+1}{k, 2} = true;
                    end
                end
            end
        end

        % 비교에 사용되지 않은 항(Prime Implicant 후보)을 최종 리스트에 추가
        for i = 1:num_vars + 1
            if ~isempty(implicants{i})
                for j = 1:size(implicants{i}, 1)
                    if implicants{i}{j, 2} == false
                        prime_implicants = [prime_implicants; implicants{i}{j, 1}];
                    end
                end
            end
        end

        % 더 이상 새로운 함축항을 찾지 못하면 반복을 종료합니다.
        if ~found_new
            break;
        end

        % 다음 단계 반복을 위해 새로운 함축항 리스트를 다음 입력으로 설정합니다.
        implicants = new_implicants;
    end
    
    % 최종적으로 찾은 Prime Implicants를 반환합니다.
    % (이 예제는 필수 주요 함축항(Essential Prime Implicants)을 선택하는 과정은 생략합니다.)
    simplified_terms = unique(prime_implicants);

    vars = 'A' : char('A' + num_vars);

    simplified_express = convert_to_boolean_expression(simplified_terms, vars)
end

% --- 내부 함수: 2진수 형태를 부울 식으로 변환 ---
function [bool_exp] = convert_to_boolean_expression(implicants_list, vars)
    bool_exp = '';
    
    for i = 1:length(implicants_list)
        term_str = '';
        current_implicant = implicants_list{i};
        
        for j = 1:length(current_implicant)
            bit = current_implicant(j);
            var = vars(j);
            
            if bit == '1'
                % '1'은 그대로 변수 (예: A)
                term_str = [term_str, var];
            elseif bit == '0'
                % '0'은 변수의 부정 (예: A')
                term_str = [term_str, var, char(39)]; % char(39)는 작은따옴표(')
            end
            % '-' (Don't Care)는 항에 포함하지 않음
        end
        
        % 각 항을 '+'로 연결
        if i > 1
            bool_exp = [bool_exp, ' + '];
        end
        bool_exp = [bool_exp, term_str];
    end
end

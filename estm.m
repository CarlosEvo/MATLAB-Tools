classdef estm
%ESTM Estimate Class
% Estm class contains the best estm value, the standard error,
% standard deviation, and sample size properties. Specified class values
% by:
% obj = estm(Val)
% Val is the best estm or data array/matrix.
%
% obj = estm(Val, SE)
% Val is the best estm or data array/matrix. SE is stanard erro.
%
% obj = estm(Val, Name, Value)
% Val is the best estm. It can only be a number.
% Name-Value pairs specify the standard error, standard deviation, and/or sample size. Only maximum of two pairs can be stated.
%
% Basic arithmnic calulations are overloaded. Complex functions can be
% overloaded with function estComp.m.
    properties
        Value@double
        Data@double
        StandardError@double
        StandardDeviation@double
        Size@double
    end
    methods

        % Set Value Functions
        function obj = estm(Val, varargin)
            p = inputParser;
            addRequired(p, 'Val', @isnumeric);
            addOptional(p, 'SEOpt', [], @isnumeric);
            addParameter(p, 'SE', [], @(x) isnumeric(x) && numel(x) == 1);
            addParameter(p, 'SD', [], @(x) isnumeric(x) && numel(x) == 1);
            addParameter(p, 'Size', [], @(x) ~mod(x, 1) && x > 0);
            parse(p, Val, varargin{:});

            % Best value manipulation
            if numel(p.Results.Val) == 1
                % If only best value is given
                obj.Data = [];
                obj.Value = p.Results.Val;
                results = struct2cell(p.Results);
                emptyIdx = num2str(find(cellfun(@isempty, results(1:4)')));
                switch emptyIdx
                    case {'1  2', '1  3'} % If no SD
                        SEBuffer = [p.Results.SEOpt, p.Results.SE];
                        obj.StandardError = SEBuffer(~isempty(SEBuffer));
                        obj.Size = p.Results.Size;
                        obj.StandardDeviation = obj.StandardError / sqrt(obj.Size);
                    case '2  3' % If no SE
                        obj.Size = p.Results.Size;
                        obj.StandardDeviation = p.Results.SD;
                        SEBuffer = [p.Results.SEOpt, p.Results.SE];
                        obj.StandardError = SEBuffer(~isempty(SEBuffer));
                    case {'1  2  4', '1  3  4'} % If SE only
                        SEBuffer = [p.Results.SEOpt, p.Results.SE];
                        obj.StandardError = SEBuffer(~isempty(SEBuffer));
                    case '2  3  4' % If SD only
                        obj.StandardDeviation = p.Results.SD;
                    case '1  2  3  4' % None
                        obj.StandardDeviation = 0;
                        obj.StandardError = 0;
                    case {'2  4', '3  4'} % No Size
                        obj.StandardDeviation = p.Results.SD;
                        SEBuffer = [p.Results.SEOpt, p.Results.SE];
                        obj.StandardError = SEBuffer(~isempty(SEBuffer));
                    case '' % All three
                        SEBuffer = [p.Results.SEOpt, p.Results.SE];
                        SE = SEBuffer(~isempty(SEBuffer));
                        if SE / p.Results.SD == sqrt(p.Results.Size)
                            obj.StandardError = SE;
                            obj.Size = p.Results.Size;
                            obj.StandardDeviation = p.Results.SD;
                        else
                            error('Relationships between uncertainties cannot be established.');
                        end
                    otherwise
                        error('Parameters invalid');
                end
            else
                if nargin ~= 1
                    % If data is stated
                    error('When data is stated, no other parameters are allowed.');
                end
                obj.Size = numel(p.Results.Val);
                obj.Data = p.Results.Val;
                obj.Value = mean(p.Results.Val);
                obj.StandardDeviation = std(p.Results.Val);
                obj.StandardError = obj.StandardDeviation / sqrt(obj.Size);
            end
        end

        % Overloading Functions
        function output = plus(obj1, obj2)
            if numel(obj2) == 1
                output = arrayfun(...
                    @(obj1) estComp(@(obj1, obj2) obj1 + obj2, obj1, obj2),...
                    obj1...
                );
            elseif numel(obj1) == 1
                output = arrayfun(...
                    @(obj2) estComp(@(obj1, obj2) obj1 + obj2, obj1, obj2),...
                    obj2...
                );
            elseif all(size(obj1) == size(obj2))
                output = arrayfun(...
                    @(obj1, obj2)...
                    estComp(@(obj1, obj2) obj1 + obj2, obj1, obj2),...
                    obj1, obj2...
                );
            elseif isvector(obj2) && any(length(obj2) == size(obj1))
                match_dim = find(length(obj2) == size(obj1));
                output_sz = size(obj1);
                repmat_sz = output_sz;
                repmat_sz(match_dim) = repmat_sz(match_dim) ./ length(obj2);
                obj2 = repmat(obj2, repmat_sz);
                output = arrayfun(...
                    @(obj1, obj2)...
                    estComp(@(obj1, obj2) obj1 + obj2, obj1, obj2),...
                    obj1, obj2...
                );
            elseif isvector(obj1) && any(length(obj1) == size(obj2))
                match_dim = find(length(obj1) == size(obj2));
                output_sz = size(obj2);
                repmat_sz = output_sz;
                repmat_sz(match_dim) = repmat_sz(match_dim) ./ length(obj1);
                obj1 = repmat(obj1, repmat_sz);
                output = arrayfun(...
                    estComp(@(obj1, obj2) obj1 + obj2, obj1, obj2),...
                    obj2, obj1...
                );
            else
                error('Matrix indices must agree.');
            end
        end
        function output = minus(obj1, obj2)
            if numel(obj2) == 1
                output = arrayfun(...
                    @(obj1) estComp(@(obj1, obj2) obj1 - obj2, obj1, obj2),...
                    obj1...
                );
            elseif numel(obj1) == 1
                output = arrayfun(...
                    @(obj2) estComp(@(obj1, obj2) obj1 - obj2, obj1, obj2),...
                    obj2...
                );
            elseif all(size(obj1) == size(obj2))
                output = arrayfun(...
                    @(obj1, obj2)...
                    estComp(@(obj1, obj2) obj1 - obj2, obj1, obj2),...
                    obj1, obj2...
                );
            elseif isvector(obj2) && any(length(obj2) == size(obj1))
                match_dim = find(length(obj2) == size(obj1));
                output_sz = size(obj1);
                repmat_sz = output_sz;
                repmat_sz(match_dim) = repmat_sz(match_dim) ./ length(obj2);
                obj2 = repmat(obj2, repmat_sz);
                output = arrayfun(...
                    @(obj1, obj2)...
                    estComp(@(obj1, obj2) obj1 - obj2, obj1, obj2),...
                    obj1, obj2...
                );
            elseif isvector(obj1) && any(length(obj1) == size(obj2))
                match_dim = find(length(obj1) == size(obj2));
                output_sz = size(obj2);
                repmat_sz = output_sz;
                repmat_sz(match_dim) = repmat_sz(match_dim) ./ length(obj1);
                obj1 = repmat(obj1, repmat_sz);
                output = arrayfun(...
                    estComp(@(obj1, obj2) obj1 - obj2, obj1, obj2),...
                    obj2, obj1...
                );
            else
                error('Matrix indices must agree.');
            end
        end
        function output = mtimes(obj1, obj2)
            if size(obj1, 2) == size(obj2, 1)
                output = repmat(estm(0), [size(obj1, 1), size(obj2, 2)]);
                for obj1_row = 1: size(obj1, 1)
                    for obj2_col = 1: size(obj2, 2)
                        output(obj1_row, obj2_col) = sum(...
                            obj1(obj1_row, :)...
                            .* obj2(:, obj2_col).'...
                        );
                    end
                end
            else
                error('Matrix indices must agree.');
            end
        end
        function output = mrdivide(obj1, obj2)
            if size(obj1, 2) == size(obj2, 1)
                output = repmat(estm(0), [size(obj1, 1), size(obj2, 2)]);
                for obj1_row = 1: size(obj1, 1)
                    for obj2_col = 1: size(obj2, 2)
                        output(obj1_row, obj2_col) = sum(...
                            obj1(obj1_row, :)...
                            ./ obj2(:, obj2_col).'...
                        );
                    end
                end
            else
                error('Matrix indices must agree.');
            end
        end
        function output = mldivide(obj1, obj2)
            if size(obj1, 2) == size(obj2, 1)
                output = repmat(estm(0), [size(obj1, 1), size(obj2, 2)]);
                for obj1_row = 1: size(obj1, 1)
                    for obj2_col = 1: size(obj2, 2)
                        output(obj1_row, obj2_col) = sum(...
                            obj1(obj1_row, :)...
                            .\ obj2(:, obj2_col).'...
                        );
                    end
                end
            else
                error('Matrix indices must agree.');
            end
        end
        function output = mpower(obj1, obj2)
            if size(obj1, 2) == size(obj2, 1)
                output = repmat(estm(0), [size(obj1, 1), size(obj2, 2)]);
                for obj1_row = 1: size(obj1, 1)
                    for obj2_col = 1: size(obj2, 2)
                        output(obj1_row, obj2_col) = sum(...
                            obj1(obj1_row, :)...
                            .^ obj2(:, obj2_col).'...
                        );
                    end
                end
            else
                error('Matrix indices must agree.');
            end
        end
        function output = sqrt(obj)
            output = arrayfun(@(obj) estComp(@(obj) sqrt(obj), obj), obj);
        end
        function output = log(obj)
            output = arrayfun(@(obj) estComp(@(obj) log(obj), obj), obj);
        end
        function output = log2(obj)
            output = arrayfun(@(obj) estComp(@(obj) log2(obj), obj), obj);
        end
        function output = log10(obj)
            output = arrayfun(@(obj) estComp(@(obj) log10(obj), obj), obj);
        end
        function output = uplus(obj)
            output = obj;
        end
        function output = uminus(obj)
            output = obj;
            output.Value = -output.Value;
        end
        function output = sin(obj)
            output = arrayfun(@(obj) estComp(@(obj) sin(obj), obj), obj);
        end
        function output = sind(obj)
            output = arrayfun(@(obj) estComp(@(obj) sin(obj), obj), obj .* pi ./ 180);
        end
        function output = cos(obj)
            output = arrayfun(@(obj) estComp(@(obj) cos(obj), obj), obj);
        end
        function output = cosd(obj)
            output = arrayfun(@(obj) estComp(@(obj) cos(obj), obj), obj .* pi ./ 180);
        end
        function output = tan(obj)
            output = arrayfun(@(obj) estComp(@(obj) tan(obj), obj), obj);
        end
        function output = tand(obj)
            output = arrayfun(@(obj) estComp(@(obj) tan(obj), obj), obj .* pi ./ 180);
        end
        function output = asin(obj)
            output = arrayfun(@(obj) estComp(@(obj) asin(obj), obj), obj);
        end
        function output = asind(obj)
            output = arrayfun(@(obj) estComp(@(obj) asin(obj) ./ pi .* 180, obj), obj);
        end
        function output = acos(obj)
            output = arrayfun(@(obj) estComp(@(obj) acos(obj), obj), obj);
        end
        function output = acosd(obj)
            output = arrayfun(@(obj) estComp(@(obj) acos(obj), obj) ./ pi .* 180, obj);
        end
        function output = atan(obj)
            output = arrayfun(@(obj) estComp(@(obj) atan(obj), obj), obj);
        end
        function output = atand(obj)
            output = arrayfun(@(obj) estComp(@(obj) atan(obj), obj) ./ pi .* 180, obj);
        end
        function [output] = times(obj1, obj2)
            if all(size(obj1) == size(obj2))
                output = arrayfun(...
                    @(x, y) estComp(@(x, y) x .* y, x, y),...
                    obj1, obj2...
                );
            elseif iscolumn(obj1) && isrow(obj2)
                row = size(obj1, 1);
                col = size(obj2, 2);
                output = repmat(estm(0, 0), row, col);
                for row_idx = 1: row
                    for col_idx = 1: col
                        output(row_idx, col_idx) = estComp(...
                            @(x, y) x .* y,...
                            obj1(row_idx), obj2(col_idx)...
                        );
                    end
                end
            elseif isrow(obj1) && iscolumn(obj2)
                row = size(obj2, 1);
                col = size(obj1, 2);
                output = repmat(estm(0, 0), row, col);
                for row_idx = 1: row
                    for col_idx = 1: col
                        output(row_idx, col_idx) = estComp(...
                            @(x, y) x .* y,...
                            obj1(col_idx), obj2(row_idx)...
                        );
                    end
                end
            else
                error('Matrix indices must agree.');
            end
        end
        function [output] = rdivide(obj1, obj2)
            if all(size(obj1) == size(obj2))
                output = arrayfun(...
                    @(x, y) estComp(@(x, y) x ./ y, x, y),...
                    obj1, obj2...
                );
            elseif iscolumn(obj1) && isrow(obj2)
                row = size(obj1, 1);
                col = size(obj2, 2);
                output = repmat(estm(0, 0), row, col);
                for row_idx = 1: row
                    for col_idx = 1: col
                        output(row_idx, col_idx) = estComp(...
                            @(x, y) x ./ y,...
                            obj1(row_idx), obj2(col_idx)...
                        );
                    end
                end
            elseif isrow(obj1) && iscolumn(obj2)
                row = size(obj2, 1);
                col = size(obj1, 2);
                output = repmat(estm(0, 0), row, col);
                for row_idx = 1: row
                    for col_idx = 1: col
                        output(row_idx, col_idx) = estComp(...
                            @(x, y) x ./ y,...
                            obj1(col_idx), obj2(row_idx)...
                        );
                    end
                end
            else
                error('Matrix indices must agree.');
            end
        end
        function [output] = ldivide(obj1, obj2)
            if all(size(obj1) == size(obj2))
                output = arrayfun(...
                    @(x, y) estComp(@(x, y) x .\ y, x, y),...
                    obj1, obj2...
                );
            elseif iscolumn(obj1) && isrow(obj2)
                row = size(obj1, 1);
                col = size(obj2, 2);
                output = repmat(estm(0, 0), row, col);
                for row_idx = 1: row
                    for col_idx = 1: col
                        output(row_idx, col_idx) = estComp(...
                            @(x, y) x .\ y,...
                            obj1(row_idx), obj2(col_idx)...
                        );
                    end
                end
            elseif isrow(obj1) && iscolumn(obj2)
                row = size(obj2, 1);
                col = size(obj1, 2);
                output = repmat(estm(0, 0), row, col);
                for row_idx = 1: row
                    for col_idx = 1: col
                        output(row_idx, col_idx) = estComp(...
                            @(x, y) x .\ y,...
                            obj1(col_idx), obj2(row_idx)...
                        );
                    end
                end
            else
                error('Matrix indices must agree.');
            end
        end
        function [output] = power(obj1, obj2)
            if all(size(obj1) == size(obj2))
                output = arrayfun(...
                    @(x, y) estComp(@(x, y) x .^ y, x, y),...
                    obj1, obj2...
                );
            elseif iscolumn(obj1) && isrow(obj2)
                row = size(obj1, 1);
                col = size(obj2, 2);
                output = repmat(estm(0, 0), row, col);
                for row_idx = 1: row
                    for col_idx = 1: col
                        output(row_idx, col_idx) = estComp(...
                            @(x, y) x .^ y,...
                            obj1(row_idx), obj2(col_idx)...
                        );
                    end
                end
            elseif isrow(obj1) && iscolumn(obj2)
                row = size(obj2, 1);
                col = size(obj1, 2);
                output = repmat(estm(0, 0), row, col);
                for row_idx = 1: row
                    for col_idx = 1: col
                        output(row_idx, col_idx) = estComp(...
                            @(x, y) x .^ y,...
                            obj1(col_idx), obj2(row_idx)...
                        );
                    end
                end
            else
                error('Matrix indices must agree.');
            end
        end
        function output = sum(obj)
            N = length(obj);
            if N > 1
                output = 0;
                for idx = 1: N
                    output = output + obj(idx);
                end
            else
                output = obj;
            end
        end
        function output = mean(obj)
            N = length(obj);
            if N > 1
                output = sum(obj) / N;
            else
                output = obj;
            end
        end
        function output = eq(obj1, obj2)
            % When only one of them is estm class
            if isa(obj1, 'estm') + isa(obj2, 'estm') == 1
                if ~isa(obj1, 'estm')
                    buffer = obj1;
                    obj1 = obj2;
                    obj2 = buffer;
                    clear(buffer);
                end
                if isempty(obj1.Size) || isempty(obj1.StandardDeviation)
                    error('Estm class must have sample size and standard deviation for t-test');
                end
                if isempty(obj1.Data)
                    t = abs((obj1.Value - obj2) / obj1.StandardError);
                    output = 1 - tcdf(t, obj1.Size - 1);
                else
                    [~, output] = ttest(obj1.Data, obj2);
                end
            else % 2-sample t-test
                [~, output] = ttest2(obj1.Data, obj2.Data);
            end
        end
        function output = gt(obj1, obj2)
            % When only one of them is estm class
            if isa(obj1, 'estm') + isa(obj2, 'estm') == 1
                if ~isa(obj1, 'estm')
                    buffer = - obj1;
                    obj1 = - obj2;
                    obj2 = buffer;
                    clear(buffer);
                end
                if isempty(obj1.Size) || isempty(obj1.StandardDeviation)
                    error('Estm class must have sample size and standard deviation for t-test');
                end
                if isempty(obj1.Data)
                    t = (obj1.Value - obj2) / obj1.StandardError;
                    output = tcdf(t, obj1.Size - 1);
                else
                    [~, p] = ttest(obj1.Data, obj2, 'Tail', 'right');
                    output = 1 - p;
                end
            else % 2-sample t-test
                [~, output] = ttest2(obj1.Data, obj2.Data, 'Tail', 'right');
            end
        end
        function output = ge(obj1, obj2)
            % When only one of them is estm class
            if isa(obj1, 'estm') + isa(obj2, 'estm') == 1
                if ~isa(obj1, 'estm')
                    buffer = - obj1;
                    obj1 = - obj2;
                    obj2 = buffer;
                    clear(buffer);
                end
                if isempty(obj1.Size) || isempty(obj1.StandardDeviation)
                    error('Estm class must have sample size and standard deviation for t-test');
                end
                if isempty(obj1.Data)
                    t = (obj1.Value - obj2) / obj1.StandardError;
                    output = tcdf(t, obj1.Size - 1);
                else
                    [~, p] = ttest(obj1.Data, obj2, 'Tail', 'right');
                    output = 1 - p;
                end
            else % 2-sample t-test
                [~, output] = ttest2(obj1.Data, obj2.Data, 'Tail', 'right');
            end
        end
        function output = lt(obj1, obj2)
            % When only one of them is estm class
            if isa(obj1, 'estm') + isa(obj2, 'estm') == 1
                if ~isa(obj1, 'estm')
                    buffer = - obj1;
                    obj1 = - obj2;
                    obj2 = buffer;
                    clear(buffer);
                end
                if isempty(obj1.Size) || isempty(obj1.StandardDeviation)
                    error('Estm class must have sample size and standard deviation for t-test');
                end
                if isempty(obj1.Data)
                    t = - (obj1.Value - obj2) / obj1.StandardError;
                    output = tcdf(t, obj1.Size - 1);
                else
                    [~, p] = ttest(obj1.Data, obj2, 'Tail', 'left');
                    output = 1 - p;
                end
            else % 2-sample t-test
                [~, output] = ttest2(obj1.Data, obj2.Data, 'Tail', 'left');
            end
        end
        function output = le(obj1, obj2)
            % When only one of them is estm class
            if isa(obj1, 'estiamte') + isa(obj2, 'estm') == 1
                if ~isa(obj1, 'estm')
                    buffer = - obj1;
                    obj1 = - obj2;
                    obj2 = buffer;
                    clear(buffer);
                end
                if isempty(obj1.Size) || isempty(obj1.StandardDeviation)
                    error('Estm class must have sample size and standard deviation for t-test');
                end
                if isempty(obj1.Data)
                    t = - (obj1.Value - obj2) / obj1.StandardError;
                    output = tcdf(t, obj1.Size - 1);
                else
                    [~, p] = ttest(obj1.Data, obj2, 'Tail', 'left');
                    output = 1 - p;
                end
            else % 2-sample t-test
                [~, output] = ttest2(obj1.Data, obj2.Data, 'Tail', 'left');
            end
        end
        function output = texstr(obj)
            nod_val = floor(log10(abs(obj.Value)));
            if abs(obj.Value) < 0.1 || abs(obj.Value) >= 1000 % If < 0.1
                val_str = sprintf('%.3f', obj.Value * 10 ^ (-nod_val));
                se_str = sprintf('%.3f', obj.StandardError * 10 ^ (-nod_val));
                output = sprintf('\\( (%s \\pm %s)e%02d \\)', val_str, se_str, nod_val);
            elseif abs(obj.Value) < 1000
                val_str = sprintf('%#.4g', obj.Value);
                val_se = sprintf('%#.4g', obj.StandardError);
                output = sprintf('\\( %s \\pm %s \\)', val_str, val_se);
            end
        end
    end
end

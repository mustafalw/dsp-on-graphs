%load monthly data from files
%N is the number of cities
N = 18;
b1 = 950;
s = zeros(N,31);
for day = 1:31
    file = int2str(day);
    s(:,day) = load(file);
end

%load coordinates
lat_long = zeros(N,2);
lat_long = load('lat_long.txt');

%calculate adjacency matrix
A = zeros(N,N);
for i = 1:N
    for j = 1:N
        a = lat_long(i,1);
        b = lat_long(i,2);
        c = lat_long(j,1);
        d = lat_long(j,2);
        A(i,j) = haversine([a,b],[c,d]);
    end    
end
A = exp(-(A./b1).^2);
row_sum = linspace(0,0,N);
for i = 1:N
    for j = 1:N
        row_sum(i) = row_sum(i) + A(i,j);
    end
end
for i = 1:N
    for j = 1:N
        if i == j
            A(i,j) = 0;
        else
            A(i,j) = A(i,j)./row_sum(i);
        end
    end
end
%G = gsp_graph(A, lat_long);
%G = gsp_compute_fourier_basis(G);
[V,D] = eig(A);
s_tilde = zeros(N);
rmse = linspace(0,0,N);
percent_error = linspace(0,0,N);
for C = 1:N
    for day = 1:31
        f_s = inv(V)*s(:,day); % Fourier transform of s(:,15)
        mod_f_s = abs(f_s); % absolute value of Fourier coefficients
        [sorted_f_s, sortingIndices] = sort(f_s,'descend'); % sort to get select the largest Fourier coefficients
        sorted_V = zeros(18,18);
        for i = 1:18 % sort the columns of eigenvector matrix for simplicity
            sorted_V(:,i) = V(:,sortingIndices(i));
        end
        f_s = sorted_f_s; % sort the Fourier coefficients themselves
        choose_C = [linspace(1,1,C), linspace(0,0,N-C)]; % C 1's followed by N-C 0's
        f_sprime = transpose(choose_C).*f_s; % choose C out of N Fouier coefficients
        s_tilde(:,day) = sorted_V*f_sprime; % regenerate s from the truncated Fourier coefficients
        rmse(C) = rmse(C) + norm(s(:,day) - s_tilde(:,day));
        percent_error(C) = percent_error(C) + norm(s(:,day) - s_tilde(:,day))/norm(s(:,day));
    end
end
x = linspace(1,N,N);
percent_error = percent_error.*(100/31); % /31 to average and multiply by 100 to convert into percent
plot(x,percent_error,'-o')
xlabel('Number of used coefficients')
ylabel('Error (%)')
%load monthly data from files
%N is the number of cities
N = 18;
s = zeros(N,31);
for i = 1:31
    file = int2str(i);
    s(:,i) = load(file);
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
max_distance = max(max(A));
%A = A./max_distance; %normalise the distances wrt the max distance
A = A./100;
A = exp(-(A.^2));
row_sum = linspace(0,0,N);
for i = 1:N
    for j = 1:N
        row_sum(i) = row_sum(i) + A(i,j);
    end
end
for i = 1:N
    for j = 1:N
            A(i,j) = A(i,j)./row_sum(i);
    end
end

%G = gsp_graph(A, lat_long);
%gsp_plot_graph(G);

%linear predictor for s(:,15)
%calculating the B vector
%taking L = 5
L = 5;
B = zeros(N,L-1);
B(:,1) = A*s(:,15);
for i = 2:(L-1)
    B(:,i) = A*B(:,i-1);
end
%filter matrix
h = inv(transpose(B)*B)*transpose(B)*s(:,15);
h_A = h(L-1).*eye(N);
if L > 2
    for i = 1:L-2
        h_A = A*h_A + h(L-1-i).*eye(N);
    end
end
h_A = A*h_A;
r = (eye(N) - h_A)*s(:,15);
s_tilde = inv(eye(N) - h_A)*r;
t = zeros(18,2);
t(:,1) = s(:,15);
t(:,2) = r;
diff = s(:,15) - s_tilde;
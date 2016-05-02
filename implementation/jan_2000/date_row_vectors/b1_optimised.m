%load monthly data from files
%N is the number of cities
N = 18;
s = zeros(N,31);
L = 11;
b1=1100;
b1_opt=b1;
minerr=100;
Day=15;
t_opt=zeros(N,2);
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
Aorg=A;
%A = A./max_distance; %normalise the distances wrt the max distance
for b1=10:10:1000  
  A = Aorg./b1;
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
  B = zeros(N,L-1);
  B(:,1) = A*s(:,Day);
  for i = 2:(L-1)
    B(:,i) = A*B(:,i-1);
  end
%filter matrix
  h = inv(transpose(B)*B)*transpose(B)*s(:,Day);
  h_A = h(L-1).*eye(N);
  if L > 2
    for i = 1:L-2
        h_A = A*h_A + h(L-1-i).*eye(N);
    end
  end
h_A = A*h_A;
r = (eye(N) - h_A)*s(:,Day);
s_tilde = inv(eye(N) - h_A)*r;
t = zeros(N,2);
t(:,1) = s(:,Day);
t(:,2) = r;
if minerr>max(abs(t(:,2))) 
    minerr=max(abs(t(:,2)));
    b1_opt=b1;
    t_opt=t;
    Aopt=A;
    hopt=h;
    h_Aopt=h_A;
end
%b1
%max(abs(t(:,2)))
%b1_opt
%minerr
end
diff = s(:,Day) - s_tilde;
%disp(t_opt(:,2))
mean(t_opt(:,2))
var(t_opt(:,2))
b1_opt
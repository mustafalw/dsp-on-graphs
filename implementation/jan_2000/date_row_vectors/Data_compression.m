%load monthly data from files
%N is the number of cities
N = 18;
Nb=64;%number of bits required to represent a floating point number
s = zeros(N,31);
L = 11;
b1=1100;
b1_opt=b1;
minerr=100;
Day=19;
bits=0;%the length in bits required to represent the error
length=100000;
L_opt=0;
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
for L=2:1:14
     minerr=100;
     for b1=50:50:1000  
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
    bits=2*log2(10000*minerr);% take the error to 4 decimal places since 2^18 is nearly 4 decimal precision
    if(length>Nb*L+N*bits)
        length=Nb*L+N*bits;
        L_opt=L;
    end
end
diff = s(:,Day) - s_tilde;
%disp(t_opt(:,2))
%mean(t_opt(:,2))
%var(t_opt(:,2))
disp('optimum value of b1')
b1_opt
disp('optimum value of L')
L_opt
disp('Minimum length in bits required')
length
disp('What the length would have been had this process not been used')
(Nb*N)
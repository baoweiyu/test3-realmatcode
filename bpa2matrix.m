%读取BPA格式数据文件，生成节点导纳矩阵
%此文件最后编辑于20160329
function [bus,branch,trans,matrix] = bpa2matrix()
%读入BPA格式数据文件的所有内容
disp(['读入BPA数据文件','bpafile','的内容']);
%打开数据文件
fid = fopen('bpafile','r');
bpainfo = cell(5000,1);
ii=1;
while (~feof(fid))
newline = fgetl(fid);
    bpainfo(ii) = {newline};
    ii = ii + 1;
end
%对未用到的数组元素置零
for jj = ii : 5000
    bpainfo(ii) = [];
end
%关闭数据文件
fclose(fid);

% 计算节点个数
busnumber = 0;
for ii = 1 : length(bpainfo)
    thisline = bpainfo{ii};
    if (length(thisline) > 2 && strcmp(thisline(1), 'B'))
        busnumber = busnumber + 1;
    end
end

%读入节点数据
t=0;
for i = 1 :length(bpainfo)
    thisline = bpainfo{i};
    
    %用空格补齐不满的行
    bb = size(thisline); 
    for ii=1:80
        cc = bb(1,2) + ii;
        thisline( cc ) = ' ';
    end
    
    if ( strcmp(thisline(1), 'B') )
        t=t+1;
        if ( strcmp(thisline(2), ' ') ) 
            bus(t).type = 1; %PQ节点
        elseif ( strcmp(thisline(2), 'Q') )
            bus(t).type = 2; %PV节点
        elseif ( strcmp(thisline(2), 'S') )
            bus(t).type = 3; %Vtheta节点
        end
        %节点编号
        a = str2num(thisline(11:14));
        bus(t).number = a;
        %节点基准电压
        a = str2num(thisline(15:18));
        bus(t).voltage = a;
        %节点分区
        a = str2num(thisline(19:20));
        bus(t).zone = a;
        %节点恒定负荷
        a = str2num(thisline(21:25)); 
        if ~isnan(a)
            bus(t).PL = a/100;
        else bus(t).PL = 0;
        end
        a = str2num(thisline(26:30));
        if ~isnan(a)
            bus(t).QL = a/100;
        else bus(t).QL = 0;
        end
        %最大有功出力
        a = str2num(thisline(39:42));
        bus(t).Pmax = a;
        %实际有功出力
        a = str2num(thisline(43:47));
       if ~isnan(a)
            bus(t).Pgen = a/100;
        else bus(t).Pgen = 0;
       end
       %实际无功出力
       a=str2num(thisline(48:52));
       if ~isnan(a)
       bus(t).Qgen=a/100;
       else bus(t).Qgen=0;
       end
        %最小无功出力
        a = str2num(thisline(53:57));
        bus(t).Qmin = a;
        %安排的电压值
        a = str2num(thisline(58:61));
        if a>10
            a=a/1000;
        end
        bus(t).Vr = a;
    end
end
        
%读入支路数据和变压器数据，对每个节点生成自导纳和互导纳
t1 = 0;
t2 = 0;
for ii = 1 :length(bpainfo)
    thisline = bpainfo{ii};
    
    %用空格补齐不满的行
    bb = size(thisline); 
    for ii=1:80
        cc = bb(1,2) + ii;
        thisline( cc ) = ' ';
    end
    
    %读入对称线路信息
    if ( strcmp(thisline(1), 'L')) 
        t1 = t1 + 1;
        %支路起始节点编号
        a = str2num(thisline( 11 : 14 ));
        branch(t1).start = a; 
        %支路末端节点编号
        a = str2num(thisline( 24 : 27 ));
        branch(t1).off = a; 
        %支路电阻
        a = str2num(thisline( 39 : 44 ));
        branch(t1).R = a; 
        %支路电抗
        a = str2num(thisline( 45 : 50 ));
        branch(t1).X = a; 
        %支路电导
        a = str2num(thisline( 51 : 56 ));
        if ~isnan(a)
            branch(t1).G = a;
        else branch(t1).G = 0; 
        end
        %支路电纳
        a = str2num(thisline( 57 : 62 ));
        if ~isnan(a)
            branch(t1).B = a;
        else branch(t1).B = 0; 
        end
    
    %读入变压器信息
    elseif (strcmp(thisline(1), 'T'))
        t2 = t2 + 1;
        %变压器支路起始节点编号
        a = str2num(thisline( 11 : 14 ));
        trans(t2).start = a; 
        %变压器支路末端节点编号
        a = str2num(thisline( 24 : 27 ));
        trans(t2).off = a; 
        %变压器等效电阻
        a = str2num(thisline( 39 : 44 ));
        if ~isnan(a)
            trans(t2).R = a;
        else trans(t2).R = 0; 
        end
        %变压器漏抗
        a = str2num(thisline( 45 : 50 ));
        if ~isnan(a)
            trans(t2).X = a;
        else trans(t2).X = 0;
        end
        %变压器等效电导
        a = str2num(thisline( 51 : 56 ));
        if ~isnan(a)
            trans(t2).G = a;
        else trans(t2).G = 0; 
        end
        %变压器激磁电纳
        a = str2num(thisline( 57 : 62 ));
        if ~isnan(a)
            trans(t2).B = a;
        else trans(t2).B = 0; 
        end        
        %分接头位置1
        a = str2num(thisline( 63 : 67 ));
        trans(t2).position1 =  a;
        %分接头位置2
		  trans(t2).position2 = 0;
        a = thisline( 68 : 72 );
		for iii=1:5
		 if a(iii)== '.'
		 trans(t2).position2 = str2num(a);
		 break;
		 end
		 end
		 
		 if trans(t2).position2 == 0
		trans(t2).position2 = str2num(a)/100;
		end
		
        %变压器变比
        trans(t2).K = trans(t2).position2 / trans(t2).position1;
    end
end

        %生成节点导纳矩阵
        matrix = zeros(busnumber,busnumber);
        for t = 1 : size(branch,2)
            b_start = branch(t).start; 
            b_off = branch(t).off;
            R = branch(t).R;
            X = branch(t).X;
            G = branch(t).G;
            B = branch(t).B;
            %自导纳
            matrix(b_start , b_start) = matrix(b_start , b_start) + 1 / (R + X*1i) + G + B*1i;
            matrix(b_off , b_off) = matrix(b_off , b_off) + 1 / (R + X*1i) + G + B*1i;
            %互导纳
            matrix(b_start , b_off) = -1 / (R + X*1i);
            matrix(b_off , b_start) = -1 / (R + X*1i);
        end
        for t = 1 : size(trans,2)
            t_start = trans(t).start;
            t_off = trans(t).off;
            R = trans(t).R;
            X = trans(t).X;
            G = trans(t).G;
            B = trans(t).B;
			K = trans(t).K;
            %自导纳
            matrix(t_start , t_start) = matrix(t_start , t_start) + 1 / (R + X*1i) + G + B*1i;
            matrix(t_off,t_off) = matrix(t_off , t_off) + 1 / (K*K*(R + X*1i));
            %互导纳
            matrix(t_start , t_off) = -1 / (K*(R + X*1i));
            matrix(t_off , t_start) = -1 / (K*(R + X*1i));
        end

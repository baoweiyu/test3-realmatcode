%��ȡBPA��ʽ�����ļ������ɽڵ㵼�ɾ���
%���ļ����༭��20160329
function [bus,branch,trans,matrix] = bpa2matrix()
%����BPA��ʽ�����ļ�����������
disp(['����BPA�����ļ�','bpafile','������']);
%�������ļ�
fid = fopen('bpafile','r');
bpainfo = cell(5000,1);
ii=1;
while (~feof(fid))
newline = fgetl(fid);
    bpainfo(ii) = {newline};
    ii = ii + 1;
end
%��δ�õ�������Ԫ������
for jj = ii : 5000
    bpainfo(ii) = [];
end
%�ر������ļ�
fclose(fid);

% ����ڵ����
busnumber = 0;
for ii = 1 : length(bpainfo)
    thisline = bpainfo{ii};
    if (length(thisline) > 2 && strcmp(thisline(1), 'B'))
        busnumber = busnumber + 1;
    end
end

%����ڵ�����
t=0;
for i = 1 :length(bpainfo)
    thisline = bpainfo{i};
    
    %�ÿո��벻������
    bb = size(thisline); 
    for ii=1:80
        cc = bb(1,2) + ii;
        thisline( cc ) = ' ';
    end
    
    if ( strcmp(thisline(1), 'B') )
        t=t+1;
        if ( strcmp(thisline(2), ' ') ) 
            bus(t).type = 1; %PQ�ڵ�
        elseif ( strcmp(thisline(2), 'Q') )
            bus(t).type = 2; %PV�ڵ�
        elseif ( strcmp(thisline(2), 'S') )
            bus(t).type = 3; %Vtheta�ڵ�
        end
        %�ڵ���
        a = str2num(thisline(11:14));
        bus(t).number = a;
        %�ڵ��׼��ѹ
        a = str2num(thisline(15:18));
        bus(t).voltage = a;
        %�ڵ����
        a = str2num(thisline(19:20));
        bus(t).zone = a;
        %�ڵ�㶨����
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
        %����й�����
        a = str2num(thisline(39:42));
        bus(t).Pmax = a;
        %ʵ���й�����
        a = str2num(thisline(43:47));
       if ~isnan(a)
            bus(t).Pgen = a/100;
        else bus(t).Pgen = 0;
       end
       %ʵ���޹�����
       a=str2num(thisline(48:52));
       if ~isnan(a)
       bus(t).Qgen=a/100;
       else bus(t).Qgen=0;
       end
        %��С�޹�����
        a = str2num(thisline(53:57));
        bus(t).Qmin = a;
        %���ŵĵ�ѹֵ
        a = str2num(thisline(58:61));
        if a>10
            a=a/1000;
        end
        bus(t).Vr = a;
    end
end
        
%����֧·���ݺͱ�ѹ�����ݣ���ÿ���ڵ������Ե��ɺͻ�����
t1 = 0;
t2 = 0;
for ii = 1 :length(bpainfo)
    thisline = bpainfo{ii};
    
    %�ÿո��벻������
    bb = size(thisline); 
    for ii=1:80
        cc = bb(1,2) + ii;
        thisline( cc ) = ' ';
    end
    
    %����Գ���·��Ϣ
    if ( strcmp(thisline(1), 'L')) 
        t1 = t1 + 1;
        %֧·��ʼ�ڵ���
        a = str2num(thisline( 11 : 14 ));
        branch(t1).start = a; 
        %֧·ĩ�˽ڵ���
        a = str2num(thisline( 24 : 27 ));
        branch(t1).off = a; 
        %֧·����
        a = str2num(thisline( 39 : 44 ));
        branch(t1).R = a; 
        %֧·�翹
        a = str2num(thisline( 45 : 50 ));
        branch(t1).X = a; 
        %֧·�絼
        a = str2num(thisline( 51 : 56 ));
        if ~isnan(a)
            branch(t1).G = a;
        else branch(t1).G = 0; 
        end
        %֧·����
        a = str2num(thisline( 57 : 62 ));
        if ~isnan(a)
            branch(t1).B = a;
        else branch(t1).B = 0; 
        end
    
    %�����ѹ����Ϣ
    elseif (strcmp(thisline(1), 'T'))
        t2 = t2 + 1;
        %��ѹ��֧·��ʼ�ڵ���
        a = str2num(thisline( 11 : 14 ));
        trans(t2).start = a; 
        %��ѹ��֧·ĩ�˽ڵ���
        a = str2num(thisline( 24 : 27 ));
        trans(t2).off = a; 
        %��ѹ����Ч����
        a = str2num(thisline( 39 : 44 ));
        if ~isnan(a)
            trans(t2).R = a;
        else trans(t2).R = 0; 
        end
        %��ѹ��©��
        a = str2num(thisline( 45 : 50 ));
        if ~isnan(a)
            trans(t2).X = a;
        else trans(t2).X = 0;
        end
        %��ѹ����Ч�絼
        a = str2num(thisline( 51 : 56 ));
        if ~isnan(a)
            trans(t2).G = a;
        else trans(t2).G = 0; 
        end
        %��ѹ�����ŵ���
        a = str2num(thisline( 57 : 62 ));
        if ~isnan(a)
            trans(t2).B = a;
        else trans(t2).B = 0; 
        end        
        %�ֽ�ͷλ��1
        a = str2num(thisline( 63 : 67 ));
        trans(t2).position1 =  a;
        %�ֽ�ͷλ��2
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
		
        %��ѹ�����
        trans(t2).K = trans(t2).position2 / trans(t2).position1;
    end
end

        %���ɽڵ㵼�ɾ���
        matrix = zeros(busnumber,busnumber);
        for t = 1 : size(branch,2)
            b_start = branch(t).start; 
            b_off = branch(t).off;
            R = branch(t).R;
            X = branch(t).X;
            G = branch(t).G;
            B = branch(t).B;
            %�Ե���
            matrix(b_start , b_start) = matrix(b_start , b_start) + 1 / (R + X*1i) + G + B*1i;
            matrix(b_off , b_off) = matrix(b_off , b_off) + 1 / (R + X*1i) + G + B*1i;
            %������
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
            %�Ե���
            matrix(t_start , t_start) = matrix(t_start , t_start) + 1 / (R + X*1i) + G + B*1i;
            matrix(t_off,t_off) = matrix(t_off , t_off) + 1 / (K*K*(R + X*1i));
            %������
            matrix(t_start , t_off) = -1 / (K*(R + X*1i));
            matrix(t_off , t_start) = -1 / (K*(R + X*1i));
        end

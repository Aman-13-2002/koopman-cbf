function U = pdU_eul(in1,in2,in3)
%PDU_EUL
%    U = PDU_EUL(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 8.1.
%    30-Aug-2020 22:56:44

KdAtt1 = in3(6,:);
KpAtt1 = in3(5,:);
KpOmegaz1 = in3(7,:);
KpVz1 = in3(4,:);
KpVxy1 = in3(3,:);
Kpxy1 = in3(1,:);
Kpz1 = in3(2,:);
eul1 = in1(4,:);
eul2 = in1(5,:);
eul3 = in1(6,:);
hoverT1 = in3(8,:);
q_d1 = in2(4,:);
q_d2 = in2(5,:);
v1 = in1(7,:);
v2 = in1(8,:);
v3 = in1(9,:);
v_d1 = in2(7,:);
v_d2 = in2(8,:);
v_d3 = in2(9,:);
w1 = in1(10,:);
w2 = in1(11,:);
w3 = in1(12,:);
w_d1 = in2(10,:);
w_d2 = in2(11,:);
w_d3 = in2(12,:);
x1 = in1(1,:);
x2 = in1(2,:);
x3 = in1(3,:);
x_d1 = in2(1,:);
x_d2 = in2(2,:);
x_d3 = in2(3,:);
t2 = cos(eul3);
t3 = sin(eul3);
t4 = v3-v_d3;
t5 = w1-w_d1;
t6 = KdAtt1.*t5;
t7 = w2-w_d2;
t8 = KdAtt1.*t7;
t9 = w3-w_d3;
t10 = KpOmegaz1.*t9;
t11 = x3-x_d3;
t12 = x2-x_d2;
t13 = t3.*v1;
t32 = t2.*v2;
t14 = t13-t32+v_d2;
t15 = KpVxy1.*t14;
t31 = Kpxy1.*t12;
t16 = eul1-q_d1+t15-t31;
t17 = KpAtt1.*t16;
t18 = t2.*v1;
t19 = t3.*v2;
t20 = t18+t19-v_d1;
t21 = KpVxy1.*t20;
t22 = x1-x_d1;
t23 = Kpxy1.*t22;
t24 = eul2-q_d2+t21+t23;
t25 = KpAtt1.*t24;
t26 = cos(eul1);
t27 = 1.0./t26;
t28 = cos(eul2);
t29 = 1.0./t28;
t30 = hoverT1.*t27.*t29;
U = [t6+t8+t10+t17+t25+t30-KpVz1.*t4-Kpz1.*t11;t6-t8-t10+t17-t25+t30-KpVz1.*t4-Kpz1.*t11;-t6-t8+t10-t17-t25+t30-KpVz1.*t4-Kpz1.*t11;-t6+t8-t10-t17+t25+t30-KpVz1.*t4-Kpz1.*t11];

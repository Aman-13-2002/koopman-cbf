function plot_experiment_int(x_rec, u_rec, u0_rec, backup_dynamics)

    global Ts am T_exp obs r
    
    for i=1:round(T_exp/Ts)
        figure(4)
        clf
        hold on
        draw_circle(obs(1),obs(2),r);
        x = x_rec(i,:);
        plot(x(1),x(2),'rO');
        quiver(x(1),x(2),0.2*x(3)*cos(x(4)),0.2*x(3)*sin(x(4)));
        N = ceil(x(3)/am/Ts);
        if N >= 1
            [~, xx] = ode45(backup_dynamics, [0:Ts:N*Ts], x);
        else
            xx = x;
        end
        for j = 1:N
            plot(xx(j,1),xx(j,2),'b*');
        end
        axis([-0.2,1.2,-0.5,0.5])
        axis equal
        drawnow
    end
end
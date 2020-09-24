function u = koopman_qp_cbf_obs(x, u0, N, system_dynamics, backup_dynamics, barrier_func_obs, alpha, func_dict, CK_pows, options,u_lim,n,m)
    
    xx = zeros(N,n);
    [d,J] = func_dict(x);
    for k=1:N
        xx(k,:)=(CK_pows{k}*d)';
        QQ(n*(k-1)+1:n*k,:)=CK_pows{k}*J;
    end
    
    Aineq = [];
    bineq = [];
    
    f_cl = backup_dynamics(x);
    [f,g] = system_dynamics(x);
    
    for k = 1:N
        x_1 = reshape(xx(k,:),n,1);

        b = barrier_func_obs(x_1);
        qq = QQ(n*(k-1)+1:n*k,:);

        h = 1e-4;
        db = zeros(n,1);
        for l = 1 : n
            x_pert = zeros(n,1);
            x_pert(l) = h;
            db(l) = (barrier_func_obs(x_1+x_pert)-b)/h;
        end
        Aineq = [Aineq;-db'*qq*g];
        bineq = [bineq;alpha*b+db'*qq*(f-f_cl)];
    end
    
    if isempty(Aineq)
        u = u0;
    else
        nonzero_inds = find(all(Aineq(:,1:m),2));
        Aineq = Aineq(nonzero_inds,:);
        bineq = bineq(nonzero_inds);
         
        Aineq = [Aineq -ones(size(Aineq,1),1)];
        H = diag([ones(1,m) 0]);
        [res,~,~] = quadprog(H,[-u0;1e6],Aineq,bineq,[],[],[u_lim(:,1);0],[u_lim(:,2);inf],[u0;0],options);
        
        u = res(1:m);
    end
end
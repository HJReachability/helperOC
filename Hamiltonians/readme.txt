
HOW TO PICK THE RIGHT HAMILTONIAN: 
—————————————————————————————————
To understand how to pick the right Hamiltonian, we have to first note the following facts:
1) Level Set Toolbox (LST) by default solves an initial value PDE (IVP). The general form of an IVP is given by: D_t V + H(p, x, t) = 0 subject to V(0) = g(x). 
2) The general form of a terminal value PDE (TVP) is given by: D_t U + H(p, x, t) = 0 subject to U(T) = g(x). An IVP can, however, be converted into a TVP. The corresponding IVP reads: D_t W - H(p, x, t) = 0 subject to W(0) = g(x). The TVP solution then is given by: U(x, t) = W(x, T-t)
3) The default form of (“unoptimized”) Hamiltonian, H, is given by p^T.f in any of the Hamiltonian file in this folder.

With these facts in mind, we can find the correct Hamiltonian of any optimal control problem of interest by selecting the appropriate uMode, dMode and tMode. See some examples below:

Example 1: Computation of a backwards reachable set  
Suppose we want to compute the backwards reachable set, where u (control) wants to minimize the value function and d (disturbance) wants to maximize the value function. The corresponding HJB PDE is thus given by the following TVP: D_t U + H(p, x, t) = 0 subject to U(T) = g(x), where H = min_u max_d p^Tf. Since LST can only solve the IVP, we can convert the above problem into an IVP using the fact (2) above:
D_t W - H(p, x, t) = 0 subject to W(0) = g(x). Equivalently, in the Hamiltonian function, we will select uMode = ‘min’, dMode = ‘max’, and ‘tMode’ = ‘backward’, which will essentially put a negative in front of the Hamiltonian as required by the above IVP. 

Example 2: Computation of a forward reachable set  
Suppose now we want to compute the forward reachable set, where both u and d wants to minimize the value function. The corresponding (optimal) HJB PDE is given by the following TVP: D_t U + H(p, x, t) = 0 subject to U(T) = g(x), where 
H = min_u min_d -p^Tf. Note a negative sign in front of p^Tf; this is because FRS can be essentially computed by replacing the dynamics f by -f. The above TVP can be equivalently written as: D_t U - H’(p, x, t) = 0 subject to U(T) = g(x), where 
H’ = max_u max_d p^Tf. Finally, this TVP can be converted into an IVP as:
D_t V + H’(p, x, t) = 0 subject to V(0) = g(x). Equivalently, in the Hamiltonian function, we will select uMode = ‘max’, dMode = ‘max’, and ‘tMode’ = ‘forward’, which will essentially NOT put a negative in front of the Hamiltonian as required by the above IVP. 
 

MIE Hamiltonian:
———————————————
  H^MIE = ??? p dot h(y,u) - b(y)
    Lower function (lower function <= x)
      Maximal reachable set/tube: ??? = min_u
      Minimal reachable set/tube: ??? = max_u
    Upper function (x <= upper function)
      Maximal reachable set/tube: ??? = max_u
      Minimal reachable set/tube: ??? = min_u
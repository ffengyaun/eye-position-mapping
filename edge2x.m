function  x=edge2x(edge)
x=edge(1:end-1)+(edge(2:end)-edge(1:end-1))./2;
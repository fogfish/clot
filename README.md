# clot - cloud toolkit

The library implements utilities for Erlang application to manage AWS resource. 

## cluster seed

The operation uses aws security group to discover all on-line nodes and tries to connect them.

```
   {ok, _} = clot:seed().
```

## elb attach

The operation attaches node to elastic load balancer. The script expects identity of ELB at `/etc/aws/elb` (it is created by cloud formation). 


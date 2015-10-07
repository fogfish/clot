# clot - cloud toolkit

The library implements utilities for Erlang application to manage AWS resource. 

## Cluster seed

The seed operation uses aws security group to discover all on-line nodes and tries to connect them.

```
   {ok, _} = clot:seed().
```




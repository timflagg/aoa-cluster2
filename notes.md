Summary:
1 mgmt cluster only
- Since Gloo Mesh and the Gloo Mesh Agent are in the same cluster, we can configure both to communicate over ClusterIP
gloo mesh 2.1.0-beta22
istio 1.13.4 with revisions
north/south and east/west gateways
cert manager deployed in cert-manager namespace

Note:
All route tables are using wildcard "*" for their hostnames which makes testing simpler but can result in routes clashing

mgmt ingress exposing:

argocd on port 80

gloo mesh on port 443 

httpbin on 80 at /get
- this route is rate limited at 20 req/sec
- when you are rate limited, the transformationfilter provides a pretty message
- log4j WAF policy enabled on this route

httpbin on 443 at /get
- this route has no limits
- log4j WAF policy enabled on this route

grafana on port 443 at /grafana

bookinfo on 80 at /productpage
- this route is rate limited at 15 req/sec
- when you are rate limited, the transformationfilter provides a pretty message
- log4j WAF policy enabled on this route

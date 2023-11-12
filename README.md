Intention:
Create a local kubernetes cluster using kind and host two sample web application using kubernetes nginx ingress or nodeport for learning ingress/nodeport.

Folder structure:
1. Kind-cluster: This is to install kind cluster using predefined yaml and expose the port to reach the k8s cluster to test Ingress or Nodeport.
2. Sampleapps_using_nodeport: Application yamls to expose application pods using nodeport.
3. Sampleapps_using_ingress: Application yamls to expose application pods using ingress.
   
Options:
   a) If you want to test ingress, then create kind cluster using yaml config "kind-config-IngressExpose.yaml" and apply install-ingress.yaml inside k8s cluster using kubectl apply. To install the applications use yamls inside the folder "Sampleapps_using_Ingress"
   b) If you want to test Nodeport, then create kind cluster using yaml config "kind-config-NodePortExpose.yaml" and use the applications yamls inside the folder "Sampleapps_using_nodeport"
 
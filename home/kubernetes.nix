{ pkgsUnstable, ... }:
{
  home.packages = with pkgsUnstable; [
    helmfile
    kind
    kubeconform
    kubectl
    kubectx
    kubernetes-helm
    kustomize
    stern
  ];

  programs.k9s = {
    enable = true;
    package = pkgsUnstable.k9s;
  };
}

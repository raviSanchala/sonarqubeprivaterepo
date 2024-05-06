# SonarQube

[SonarQube](https://www.sonarqube.org/) is an open sourced code quality scanning tool. This installation guide is based on [official SonarQube helm chart from SonarSource](https://github.com/SonarSource/helm-chart-sonarqube/tree/master/charts/sonarqube-lts), bootstraping a SonarQube LTS instance with a PostgreSQL database.

## Prerequisites

- Kubernetes 1.19+
- Create values.yaml and populate the file with ingress parameters below.

```yaml
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: "nginx"
    kubernetes.io/ingress.allow-http: "false"
    nginx.ingress.kubernetes.io/proxy-body-size: "8000m"
    nginx.ingress.kubernetes.io/rewrite-target: /$1
    nginx.ingress.kubernetes.io/use-regex: "true"
  hosts:
    - name: dev.sonarqube.corpnet4.net
      #  - name: sonaqube.dev.developer.gsk.com
      path: "/?(.*)"
      # For additional control over serviceName and servicePort
      # serviceName: someService
      # servicePort: somePort
  tls:
    - secretName: sonarqube-tls
      hosts:
        - dev.sonarqube.corpnet4.net
```

- Helm
- Helmsman

## SonarQube specific configuration

### SAML

To configure authentication using SAML, the application should be registered in [Authentication and Identity Repository (AIR)](https://air.corpnet4.com/air/).

Token signature verification certificate (public certificate for federation.corpnet4.com) can be downloaded from main page of AIR, or from Federation Info page for the app. Certificate as multi-line text can be joined into single line and added to values.\*.yaml file as shown below:

```yaml
sonarProperties:
   (...)
   sonar.auth.saml.certificate.secured: |
     -----BEGIN CERTIFICATE----- XYZ(...)123  -----END CERTIFICATE-----
```

**IMPORTANT!** When registering application in AIR ensure that SAML response contains all the attributes that SonarQube uses for mapping, listed below. Attributes can be verified using application's Metadata URL, displayed in Federation info in AIR. Adding some of them (e.g. `groups`) may be required, based on the ticket sent to AIR/SSO Support team.

```yaml
sonarProperties:
   (...)
  sonar.auth.saml.user.login: immutableID
  sonar.auth.saml.user.name: givenname
  sonar.auth.saml.user.email: email
  sonar.auth.saml.group.name: groups
```

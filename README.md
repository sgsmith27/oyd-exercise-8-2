# Exercise 8.2 — OIDC Federation + AWS Secrets Manager

Curso: Optimizaciones y Desempeño — Cloud Deployment Automation

## Objetivo

Eliminar el uso de credenciales AWS de larga duración en GitHub Actions mediante OpenID Connect (OIDC) Federation y almacenar secretos de aplicación en AWS Secrets Manager.

La autenticación del pipeline se realiza mediante tokens temporales emitidos por GitHub Actions y validados por AWS IAM.

---

## Arquitectura

```text
GitHub Actions
       │
       │ OIDC Token
       ▼
AWS IAM OIDC Provider
       │
       ▼
IAM Role (ci_runner)
       │
       ▼
Temporary AWS Credentials
       │
       ▼
Terraform Validate
```

---

## Recursos Implementados

### OIDC Provider

```text
https://token.actions.githubusercontent.com
```

Configuración:

* client_id_list = sts.amazonaws.com
* thumbprint_list = 6938fd4d98bab03faadb97b34396831e3780aea1

---

### IAM Role

Nombre:

```text
sgsmith27-oyd-8-2-ci-runner
```

Trust Policy:

* Principal Federated: GitHub OIDC Provider
* Action: sts:AssumeRoleWithWebIdentity

Condiciones:

```text
token.actions.githubusercontent.com:sub
=
repo:sgsmith27/oyd-exercise-8-2:ref:refs/heads/main
```

```text
token.actions.githubusercontent.com:aud
=
sts.amazonaws.com
```

Se utilizó:

```text
StringEquals
```

sin wildcards para cumplir el principio de mínimo privilegio.

---

### AWS Secrets Manager

Secret creado:

```text
sgsmith27-oyd-8-2-db-password
```

Valor inicial:

```text
changeme-in-rotation
```

La configuración incluye:

```hcl
lifecycle {
  ignore_changes = [
    secret_string
  ]
}
```

para evitar drift cuando el secreto sea rotado manualmente.

---

## Outputs

### IAM Role ARN

```text
arn:aws:iam::577133972654:role/sgsmith27-oyd-8-2-ci-runner
```

### Secret ARN

Disponible mediante Terraform Output:

```bash
terraform output secret_arn
```

---

## GitHub Actions

Workflow:

```text
.github/workflows/ci.yml
```

Características:

* OIDC Federation
* No utiliza Access Keys
* No utiliza Secret Access Keys
* Terraform Init
* Terraform Validate

Permisos:

```yaml
permissions:
  contents: read
  id-token: write
```

Autenticación:

```yaml
role-to-assume: ${{ secrets.AWS_CI_ROLE_ARN }}
```

---

## Comandos Ejecutados

Inicialización:

```bash
terraform init
```

Validación:

```bash
terraform validate
```

Despliegue:

```bash
terraform apply -var-file=dev.tfvars -auto-approve
```

---

## Evidencia

Ejecución exitosa del workflow:
![ci-run](/evidence/ci-run.PNG)


La evidencia muestra:

* Workflow exitoso
* Job validate exitoso
* Paso "Configure AWS credentials with OIDC"
* Terraform Init exitoso
* Terraform Validate exitoso

---

## Conceptos Aplicados

* OpenID Connect (OIDC)
* IAM Federation
* GitHub Actions OIDC Authentication
* Least Privilege Access
* AWS Secrets Manager
* Secret Rotation Readiness
* Terraform IAM Resources
* CI/CD Security
* Temporary Credentials
* Identity Federation

---

## Autor
Sergio Geovany García Smith

Carnet 2500813
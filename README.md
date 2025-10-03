# DevOps Assignment – EKS, Docker, Helm, GitHub Actions

מסמך זה מסביר איך הפרויקט בנוי ואיך מפעילים אותו מקצה לקצה.

## מבנה הפרויקט (הסבר קצר בעברית)

- `app/` – אפליקציית Flask ודוקראיזציה (`Dockerfile`).
- `terraform/` – קוד Terraform להקמת תשתיות AWS: S3 ל‑state, VPC, EKS, Node Groups, ECR, IAM ו‑Outputs.
- `helm/app/` – Helm chart לפריסה ל‑EKS (Deployment, Service, Ingress).
- `.github/workflows/` – GitHub Actions לבניית image ודיפלוימנט ל‑EKS.
- `.secrets/` – תקיית סודות מקומית שלא עולה ל‑GitHub (מוגדרת ב‑`.gitignore`). כאן ניתן לשמור קבצים כמו `kubeconfig`, קובצי ערכים סודיים של Helm, או פרטי התחברות מקומיים. ב‑GitHub משתמשים ב‑Secrets של הריפוזיטורי במקום.

> הערה: אין לשים סודות בקוד. שמרו קבצי קונפידנציאליים (כמו `aws_credentials`, `kubeconfig`, קבצי ערכים רגישים) תחת `.secrets/` בלבד או ב‑GitHub Secrets.

## תנאים מקדימים

- חשבון AWS עם הרשאות להקים ECR, S3, VPC, EKS, IAM.
- מותקן מקומית: `awscli`, `kubectl`, `helm`, `terraform`, `docker`.
- התחברות ל‑AWS (`aws configure`) ו‑ECR (`aws ecr get-login-password`).

## אפליקציה ו‑Docker

בניית image מקומית והעלאה ל‑ECR:

```bash
# החליפו <ACCOUNT_ID> ו‑<REGION> ושם הריפו שנוצר ב‑Terraform
REPO="<ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/interview-app"
docker build -t interview-app:latest ./app
aws ecr get-login-password --region <REGION> | docker login --username AWS --password-stdin ${REPO%
}
docker tag interview-app:latest $REPO:latest
docker push $REPO:latest
```

## Terraform – הקמת תשתיות

```bash
cd terraform
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

Outputs חשובים יופיעו בסיום: `cluster_name`, `cluster_endpoint`, `ecr_url`, `node_role_arn` ועוד.

לאחר יצירה, עדכנו קובץ kubeconfig והקשר לקלאסטר:

```bash
aws eks update-kubeconfig --name <cluster_name> --region <REGION>
```

## Helm – פריסה ל‑EKS

```bash
helm upgrade --install interview-app ./helm/app \
  --set image.repository=<ECR_URL> \
  --set image.tag=latest
```

לאחר הפריסה, ה‑Service/Ingress יחזירו כתובת ציבורית. אפשר למצוא אותה עם:

```bash
kubectl get svc,ingress -n default
```

## GitHub Actions

ה‑workflow הראשון בונה ו‑push ל‑ECR בכל push ל‑`main`. השני מבצע `helm upgrade` מול הקלאסטר. הגדירו ב‑GitHub Secrets את המשתנים הבאים:

- `AWS_ACCOUNT_ID`, `AWS_REGION`
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
- `EKS_CLUSTER_NAME`

## ניקוי משאבים

```bash
cd terraform
terraform destroy
```



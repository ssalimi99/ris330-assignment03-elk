# RIS330 Assignment 03 - ELK Stack and Logging

This folder contains a complete, reproducible implementation kit for Assignment 03.
It is built for a Linux VM (Ubuntu/Debian family) and uses **ELK 7.x** for simpler
single-node classroom setup.

## What is included

- `vm/`: VM prep notes and requirement check script
- `install/`: ELK install and service bootstrap script
- `configs/`: config files you can submit with your report
- `ingest/`: scripts to download Apache logs and ingest with Filebeat
- `demo/`: in-class demonstration runbook
- `report/`: editable report template (`.docx` + `.rtf`)
- `submission/`: submission manifest/checklist

## Recommended execution order on your Linux VM

1. Check VM resources:
   - `bash vm/check_vm_requirements.sh`
2. Install and configure ELK:
   - `bash install/install_elk7.sh`
3. Download Apache sample logs:
   - `bash ingest/01_fetch_sample_logs.sh`
4. Configure Filebeat Apache module + setup dashboards:
   - `bash ingest/02_configure_filebeat_apache.sh`
5. Verify ingestion and dashboard readiness:
   - `bash ingest/03_verify_ingestion.sh`
6. If verification shows **0 documents** (common on Ubuntu):
   - `bash ingest/04_fix_zero_documents.sh`
   - Then run step 5 again.
7. Rehearse class demo:
   - Follow `demo/DEMO_RUNBOOK.md`
8. Complete and submit report:
   - Open `report/Assignment03_Report_Template.docx`
   - Follow `submission/SUBMISSION_CHECKLIST.md`

## If you downloaded ZIP and then ran `git init` / `git fetch`

Link `main` to GitHub so `git pull` works:

```bash
git branch --set-upstream-to=origin/main main
git pull
```

## Important notes

- **Run the ingest scripts in order:** fetch logs (`01`) *before* or together with Filebeat setup (`02`). If Filebeat was configured first, re-run `01` (it restarts Filebeat) or run `04_fix_zero_documents.sh`.
- This implementation intentionally uses ELK 7.x to reduce security overhead for class demo.
- If you choose ELK 8.x, you must add TLS/auth bootstrap steps.
- Keep all screenshots compliant:
  - VM name
  - student number
  - current date/time

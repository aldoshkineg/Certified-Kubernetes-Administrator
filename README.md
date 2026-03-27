# Certified Kubernetes Administrator (CKA) Study Repository

![CKA](https://img.shields.io/badge/CKA-Study%20Notes-blue)
![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.35-blue)
![Status](https://img.shields.io/badge/Status-Passed%20(89%25)-brightgreen)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

This repository contains my study notes, practice exercises (~200 questions),
and troubleshooting write-ups to help prepare for the Certified Kubernetes Administrator (CKA) exam.

---

## 📚 Repository Layout

```

.
├── README.md
├── domains/            # Exam domain documentation (aligned with CKA weights)
├── exercises/          # Practice tasks (organized by domain)
├── cheatsheets/        # Quick command/reference snippets
├── docs/               # General theory and study resources
├── installation/       # kubeadm / cluster bootstrap materials
├── packages/           # Example manifests and configurations
└── tools/              # Helper tools and notes

```

---

## 📖 Exam Information

* **Kubernetes Version**: v1.35
* **Duration**: 2 hours
* **Questions**: ~17 (can be solved in any order)
* **Practice Exams**: 2 simulated sessions on Killer.sh
* **Pass Mark**: 66%
* **Retakes**: 1 free retake if you fail the first attempt
* **System Requirements**: Ubuntu, Windows, or macOS (PSI Secure Browser)
* **Environment**: Remote-proctored (webcam + microphone required)
* **ID Required**: Government-issued ID or passport

### CKA Domain Weights

* **Troubleshooting**: 30%
* **Cluster Architecture, Installation & Configuration**: 25%
* **Services & Networking**: 20%
* **Workloads & Scheduling**: 15%
* **Storage**: 10%

---

## 🏆 My Case

* Ubuntu 22.04; PSI browser not working on Gentoo + i3wm (used dual-boot on a free volume)
* Ultrabook 14", 1920 × 1080 (FHD); used scaling when needed (`Ctrl + -`)
* USB webcam
* Practiced on KodeKloud mock exam series
* Used a **CK-X** local exam-like environment
* Local clusters with **Minikube** and **Kubeadm** (see `installation/kubeadm`)
* VPN connection (vless-reality + hysteria2), stable with low latency
* Passed on **2026-03-24** with a score of **89%** (time spent: 1h 30m)

---

## 🔗 Useful Links

* https://video-diagnostics.twilio.com/ — Check connection RTT
* https://syscheck.bridge.psiexams.com/ — PSI system check
* https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/ — Official CKA resources
* https://killer.sh/ — Practice environment (2 attempts, 36h access)
* https://learn.kodekloud.com/courses/ultimate-certified-kubernetes-administrator-cka-mock-exam-series — KodeKloud mock exams
* https://app.sailor.sh/login — Sailor.sh mock exams
* https://github.com/sailor-sh/CK-X — Local exam-like environment

---

## 🚀 Getting Started (Recommended Workflow)

1. Start with high-weight domains in `domains/` (especially Troubleshooting and Cluster Architecture)
2. Practice hands-on using `exercises/`
3. Use `cheatsheets/` for quick command lookup during practice
4. Use `cheatsheets/doc-links.md` for fast access to official documentation

---

## 📝 Exam Tips

* Practice on weekdays (more flexible scheduling)
* Install and test PSI Secure Browser **before exam day**
* Use both Killer.sh sessions in the final week
* Ensure a stable internet connection for the full exam duration
* Prepare a quiet, clean testing environment
* Allow ~30 minutes for check-in
* Keep passport/ID ready

### Common Pitfalls

* UDP connectivity issues may occur — report immediately to the proctor
* Do not panic if the environment behaves unexpectedly; it may recover quickly

---

## ⏱️ Time Management: Optimal Question Order

1. **First 5 mins:** Brain dump key commands + scan all questions
2. **Pass 1 (Easy):** Solve all quick wins (<5 mins each)
3. **Pass 2 (Medium):** Work through moderate/high-value questions
4. **Pass 3 (Risky):** Handle disruptive tasks last (e.g., etcd backup/restore)

---

## ⚠️ Crucial Tips

* Stay calm and focused
* Read each task twice
* Set context immediately: `kubectl config use-context <context>`
* Check the info panel (`i`) for hidden hints (namespace, resources)
* If stuck >7 minutes → flag and move on
* Return later with a fresh perspective

## ℹ️ Disclaimer

This repository contains only personal study notes and independently created practice
materials for Kubernetes and CKA preparation. It does not include or reproduce
any official or confidential exam content. Any resemblance to real exam
questions is purely coincidental.

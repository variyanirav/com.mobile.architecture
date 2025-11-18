# SECURITY CHECKLIST

Use this as a living checklist and add notes from Day 14 onwards.

## Secrets & Credentials
- [ ] No secrets committed; use env vars/secret manager.
- [ ] Obfuscation enabled for release builds if applicable.

## Data Protection
- [ ] Use `flutter_secure_storage` (or platform keychain/keystore) for sensitive data.
- [ ] Consider database encryption (if required by NFRs).

## Network
- [ ] HTTPS enforced; certificate pinning considered for high-sensitivity flows.
- [ ] Token handling: refresh flows, storage, revocation strategy.

## Dependency Hygiene
- [ ] Regularly audit dependencies; track licenses.
- [ ] SDKs reviewed for privacy/compliance implications.

## Threat Model (mini)
Assets → Threats → Mitigations table (start simple):

| Asset | Threat | Mitigation |
|-------|--------|------------|
| Access token | Theft via logs | Never log secrets; secure storage |
| PII | Device compromise | OS protections, encryption at rest |
| API endpoints | MITM | TLS, optional pinning |

# MoneyApp

MoneyApp je Flutter aplikacija koja simulira mobilnu bankarsku aplikaciju. Razvijena je kao tehnički zadatak koristeći BloC arhitekturu za upravljanje stanjem i navigaciju.

---

## Opis aplikacije

Aplikacija omogućava korisniku osnovne bankarske funkcionalnosti kroz jednostavan i moderan interfejs.

Glavne funkcionalnosti:

- pregled liste transakcija  
- plaćanje (Pay)  
- dopuna računa (Top-up)  
- apliciranje za kredit (Loan application)  

Aplikacija automatski ažurira balans i transakcije u zavisnosti od korisničkih akcija.

---

## Funkcionalnosti

### Transactions
- prikaz trenutnog balansa  
- lista transakcija (PAYMENT / TOP-UP)  
- grupisanje po datumima (TODAY, YESTERDAY, itd.)  
- različit prikaz za tipove transakcija  

### Pay
- unos iznosa  
- unos naziva transakcije  
- automatsko dodavanje transakcije i ažuriranje balansa  

### Top Up
- unos iznosa  
- dodavanje TOP-UP transakcije  
- povećanje balansa  

### Transaction Details
- prikaz detalja transakcije  
- split the bill (dijeljenje iznosa)  
- repeating payment (ponavljanje transakcije)  
- prikaz poruke za pomoć  

### Loan Application
- unos plate, troškova, iznosa i roka kredita  
- automatska odluka (approved / declined)  
- integracija sa API-em za random broj  
- pravila odlučivanja na osnovu finansijskih parametara  

---

## Tehnologije

- Flutter  
- Dart  
- BloC (flutter_bloc)  
- REST API (randomnumberapi.com)  
- JSON / lokalna simulacija backend-a  

---

## Arhitektura

Aplikacija koristi BloC arhitekturu:

- State Management putem BloC-a  
- Event-driven pristup  
- Odvojena logika od UI sloja  

---

Slike aplikacije: 


<img width="200" height="413" alt="Screenshot 2025-08-10 203144" src="https://github.com/user-attachments/assets/2be4b971-65c6-4d77-9823-c5f75998885c" />

<img width="200" height="413" alt="Screenshot 2025-08-10 225013" src="https://github.com/user-attachments/assets/1b3748a3-9caa-450a-be32-bd3a73d6fe8c" />

<img width="200" height="413" alt="Screenshot 2025-08-05 201226" src="https://github.com/user-attachments/assets/1232cc8c-6bb2-46ad-b55b-ae991345bae0" />





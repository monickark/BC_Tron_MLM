# BC_Tron_MLM

## Contract Deployment

### Function call Values
    Function : Contract deployment	\
    Msg.sender : TJHYbk7q2EuMJJZeEF6cxPBEDg9kG1sR1j \
    msg.value : 0 \
    _referrerID : 0

![Function @ Deployment](<images/1.ContractDeployment.png>)

## User Registration
### Function call Values
    Function : regUser	\
    Msg.sender : TRc7JCUtMopM3sADYDj5KUBhzD1K3q1JsR \
    msg.value : 150 \
    _referrerID : 1

    *Tron Balance Before*
    TJHYbk7q2EuMJJZeEF6cxPBEDg9kG1sR1j : 1000000
    TRc7JCUtMopM3sADYDj5KUBhzD1K3q1JsR : 1000000

    *Tron Balance After*
    TJHYbk7q2EuMJJZeEF6cxPBEDg9kG1sR1j : 1000150
    TRc7JCUtMopM3sADYDj5KUBhzD1K3q1JsR : 999850
![User Registration](<images/2.UserRegistration.png>)

### After added 3 people in level1 of user1 who has owner as referrer
![Level1TrxBalAfter3referrer](<images/3.Level1TrxBalAfter3referrer.png>)

### After second referral transfer amount to contract
![alt text](<images/4.2ndreferrerAmountTransferToContract.png>)

![alt text](images/4.1.2ndReferralAmountTransferChanges.png)

## tronbox
### tronbox runtime environment
install docker
docker pull tronbox/tre
docker run -it \
-p 8080:8080 \
--rm \
--name tron \
tronbox/tre

### tronbox project setup
npm install -g tronbox
tronbox init
replace private key in tronbox.js

### Handling tronbox
tronbox compile
tronbox migrate




Available Accounts
==================

(0) TPPS8btv2bub5XWkZsX935Y9FjHSXRBPAL (10000 TRX)
(1) TMkbgQyWZoNbKrSr2PbACABd6U1XXP7Eva (10000 TRX)
(2) TU3YVhd1YP1jkStkqbJUQfXAQZUjNCjMy9 (10000 TRX)
(3) TDyhC9hUP9LZRBWKhb1ZKYsRerhoyKb8hZ (10000 TRX)
(4) TJS1Zcd7r2vPd2YdAn5hrzpWC76KiStG94 (10000 TRX)
(5) TCtR2M5pv7sh3J2ZprKtpeWZ6hsWoQHVyR (10000 TRX)
(6) TVdmpgn3y6JjcNCcCfstdCR8fC6r6EfvrX (10000 TRX)
(7) TC1coPNLPJHLadQSszurjgFrCzQPf5z3jd (10000 TRX)
(8) TTNKh2oxmAKUAhNKgndfTvX3GSercwftNV (10000 TRX)
(9) TFMTL1czdpoKMMHuKtj25GXXVnuxc38g6E (10000 TRX)

Private Keys
==================

(0) 9a20eecb3a2021a8fe2dda3e2cee6b8e01076287240f915e6fd0e5e56450cfcd
(1) ba7122c39adfde59d46fef7b24001d372cfcc5f9fe2254f21aa8b23bd9730c5d
(2) 7ba61ceec81b8c7e2b5b49589005beabfa347d4fd98e3d237e2846f7360debcd
(3) ac3c2d207614e2a4f326afefd9e1284ec6438873edda61e8cd73d6b38d3b5868
(4) 122086cad7361e53fef5c034da87d63f947da2bf9126f9ec6954772b4d4c84ea
(5) 34bbf133df0c3e9f22496d663cb21684ddfedb8a7be06aa3cf2bb8c5eee8003e
(6) 209953db7af7058f081dcc8c9a5c9e6bef3ed04b0d088a67dcacf8abbb1df7e8
(7) fc99a59cf333904fa8583d56f2726a98d0f6342b20a8b69119aabe95eda370d3
(8) dbe9449e6246ad90cbf661dc2cd11baf092e6f6b2e43e6c959bd1dcbabaa400e
(9) 92a6c2833ce6a0ef8196176c6bc75ab30c1dcf4d67149c03a9496ee801bbf34a

HD Wallet
==================
Mnemonic:      edge admit dice fame winter float lake retreat broccoli park fragile car
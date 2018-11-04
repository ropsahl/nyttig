# hb-openshift-api
Denne tjenesten er laget for å kjøre på Openshift og skal lage prosjekter og andre ressurser som trengs for Husbankens bruk av Openshift.

## eksempel-bruk
(sudo pip install httpie)

**lage prosjekt:**
echo '{"name":"nojtest12", "systemgruppe":"testssdfsdfystem"}' | http POST http://hb-openshift-api-hb-verktoy.cluster.dev/create 

**liste prosjekt:**
http http://hb-openshift-api-hb-verktoy.cluster.dev/list

**Eksempler på tjenester som kan implementeres:**
* Liste ut systemgrupper
* lage nye prosjekter
* Liste ut URLer til prosjekter.

## Tilgang/Installasjon:
En serviceaccount brukes til å kjøre applikasjonen. Den blir gitt rettigheter som beskrevet her.
Det er fila clusterpolicy.json som er sjekket inn her som gir rettighetene som trengs.

Installasjon skjer i to steg:

1 Lage serviceaccount og sette rettigheter:
```
oc create -f=clusterpolicy.json
oc create serviceaccount hb-openshift-api
oc adm policy add-cluster-role-to-user create_project_role system:serviceaccount:hb-verktoy:hb-openshift-api
```

2 Installer og konfigurer tjeneste:
* Konfigurer jobb i Jenkins (openshift hb-verktøy)
* Kjør bygg som vil sette opp tjeneste


https://access.redhat.com/solutions/2988521

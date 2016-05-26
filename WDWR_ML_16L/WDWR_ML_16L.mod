/*********************************************
 * OPL  Model
 * Author: Micha� Lutoborski
 * Creation Date: 26-05-2016 at 19:41:49
 *********************************************/

// Wczytywanie parametr�w

int nbMachines = ...;
int nbMonths = ...;
int nbProducts = ...;

int distrColNb = ...;
int distrRowNb = ...; // Liczba pr�bek wygenerowanych - na koniec

// Utworzenie wektor�w do indeksowania
{int} machines = asSet(1..nbMachines);
{int} months = asSet(1..nbMonths);
{int} products = asSet(1..nbProducts);
{int} distrCol = asSet(1..distrColNb);

int maxMachines[machines] = ...;

float prodCost[machines][products] = ...;
			
int monthMax[months][products] = ...;

int storageMax[products] = ...;
int storageCost = ...;

int nbHours = ...;

int mi = ...;

int covariance[distrCol][distrCol] = ...;


 
/*********************************************
 * OPL  Model
 * Author: Micha³ Lutoborski
 * Creation Date: 26-05-2016 at 19:41:49
 *********************************************/

// Wczytywanie parametrów
int nbMachines = ...;
int nbMonths = ...;
int nbProducts = ...;

int distrColNb = ...;
int distrRowNb = ...; // Liczba próbek wygenerowanych - na koniec

// Utworzenie wektorów do indeksowania
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

// Zmienne decyzyjne
dvar int producedQuant[months][products]; 	// Liczba wyprodukowanych
dvar int soldQuant[months][products];		// Liczba sprzedanych
dvar int stockQuant[months][products];		// Liczba w magazynie
dvar boolean production[machines][products];// Zmienne steruj¹ce jednoczesn¹ prac¹ maszyn







 /***************** COPY *****************/

 // Data reading
int nrows = ...;
int ncols = ...;

{int} rows = asSet(1..nrows);
{int} cols = asSet(1..ncols);

// Values
float costF1_M1 = ...;
float costF2_M2 = ...;
//float mi[cols] = ...;
float covr[cols][cols] = ... ;
int maxF1 = ...;
int maxF2 = ...;
int maxM1 = ...;
int maxM2 = ...;
int needK1 = ...;
int needK2 = ...;
float vecR[rows][cols] = ...;

// MPO
int uuAC = ...;
int unAC = ...;
int uuWR = ...;
int unWR = ...;
int uMPO = ...;
int uASP = ...;
float utWhlRisk = ...;
float ndWhlRisk = ...;
float lmbWhlRisk = 1/(ndWhlRisk-utWhlRisk);
float utAvgCost = ...;
float ndAvgCost = ...;
float lmbAvgCost = 1/(ndAvgCost-utAvgCost);
float beta = ...;
float epsilon = ...;
float asWhlRisk = ...;
float asAvgCost = ...;

// Variables
dvar int amtK1_F1;
dvar int amtK1_F2;
dvar int amtK1_M2;
dvar int amtK2_F1;
dvar int amtK2_M1;
dvar int amtK2_M2;
dvar boolean uK1_F1;
dvar boolean uK1_F2;
dvar boolean uK1_M2;
dvar boolean uK2_F1;
dvar boolean uK2_M1;
dvar boolean uK2_M2;

// MPO
dvar float v;
dvar float MPOac;
dvar float MPOwr;
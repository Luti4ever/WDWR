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
int distrRowNb = ...;

// Utworzenie wektor�w do indeksowania
{int} machines = asSet(1..nbMachines);
{int} months = asSet(1..nbMonths);
{int} products = asSet(1..nbProducts);
{int} distrCol = asSet(1..distrColNb);
{int} distrRow = asSet(1..distrRowNb);

int maxMachines[machines] = ...;

float prodCost[machines][products] = ...;
			
int monthMax[months][products] = ...;

int storageMax[products] = ...;
int storageCost = ...;

int nbHours = ...;

int mi[distrCol] = ...;

int covariance[distrCol][distrCol] = ...;

float sellProfitR[distrRow][distrCol] = ...;

// MPO
float asAvgProfit = ...;
float utAvgProfit = ...;
float ndAvgProfit = ...;
float lmbAvgProfit = 1/(utAvgProfit - ndAvgProfit);

float asMaxRisk = ...;
float utMaxRisk = ...;
float ndMaxRisk = ...;
float lmbMaxRisk = 1/(ndMaxRisk - utMaxRisk); // Dla ryzyka utopia <= nadiru, wi�c odwracamy znaki, �eby lambda > 0

float beta = ...;
float epsilon = ...;


// Zmienne decyzyjne
dvar int producedQuant[months][products]; 	// Liczba wyprodukowanych
dvar int soldQuant[months][products];		// Liczba sprzedanych
dvar int stockQuant[months][products];		// Liczba w magazynie
dvar float elapsedTime[months][machines][products];	// Czas wykorzystany na maszynach na dane produkty

// MPO
dvar float z;
dvar float mpoAvgProfit;
dvar float mpoMaxRisk;

// Kryteria
dexpr float profit[i in distrRow] = sum(m in months, p in products) (soldQuant[m][p]*sellProfitR[i][p] - stockQuant[m][p]*storageCost);
dexpr float avgProfit = sum(i in distrRow)(profit[i])/distrRowNb;

dexpr float risk[i in distrRow] = abs(avgProfit-profit[i]);
dexpr float maxRisk = max(i in distrRow) risk[i];

dexpr float objective = z + epsilon*(mpoAvgProfit + mpoMaxRisk);

// Funkcja celu
maximize objective;

// Ograniczenia
subject to {
  // Wi�ksze ni� 0
  forall(m in months, mc in machines, p in products) {
    elapsedTime[m][mc][p] >= 0;
    producedQuant[m][p] >= 0;
    soldQuant[m][p] >= 0;
    stockQuant[m][p] >= 0;
  }    
  
  // Produkcja
  
	forall(m in months, mc in machines) {
	  sum(p in products) (elapsedTime[m][mc][p]) <= maxMachines[mc]*nbHours;
  }
   	
 	forall(m in months, p in products, mc in machines) {
 	  elapsedTime[m][mc][p] == producedQuant[m][p]*prodCost[mc][p];
  }
  
  	forall(m in months, mc in products, p in products) {
 	  elapsedTime[m][mc][p] <= nbHours;
  }
	
  // Rynek
 	forall(m in months, p in products) {
 	  soldQuant[m][p] <= monthMax[m][p];
  }
  	
  	forall(m in months, p in products) {
  	  if(m == 1) {
  	    soldQuant[m][p] == producedQuant[m][p];
     }
     else {
       soldQuant[m][p] == producedQuant[m][p] + stockQuant[m-1][p];
     }
  }
  
    /* Warunek sprzedawania produkt�w P4 w miesi�cach w kt�rych sprzedawany jest P1 lub P2 mo�na rozumie� dwojako.
    Je�eli mamy sprzedawa� P4 jednocze�nie z produktem P1 lub P2, to warunek jest prosty: suma sprzedanych P1 i P2 w danym miesi�cu
    musi by� r�wna sprzedanej P4. - warunek jest aktualnie zakodowany w skrypcie poni�ej tego komentarza, przetestowany i dzia�a.
    W przypadku gdy ilo�ci nie musz� si� pokrywa� problem jest do rozwi�zania.
    Wprowadzi� poprawk� po konsultacjach z prowadz�cym.
    */
  	
  	forall(m in months) {
  	  soldQuant[m][1] + soldQuant[m][2] == soldQuant[m][4];
   }
  
  // Sk�ad
  	forall(m in months, p in products) {
  	  stockQuant[m][p] <= storageMax[p];
  	  if(m == 3) {
  	  	stockQuant[m][p] >= 50;
    }  	  	
   }
   
   // MPO
   z <= mpoAvgProfit;
   z <= mpoMaxRisk;
   
   mpoAvgProfit <= beta * lmbAvgProfit * (avgProfit - asAvgProfit);
   mpoAvgProfit <= lmbAvgProfit * (avgProfit - asAvgProfit);
   
   mpoMaxRisk <= beta * lmbMaxRisk * (asMaxRisk - maxRisk);
   mpoMaxRisk <= lmbMaxRisk * (asMaxRisk - maxRisk);   
}
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

float sellProfitR[distrCol][distrCol] = ...;

// Zmienne decyzyjne
dvar int producedQuant[months][products]; 	// Liczba wyprodukowanych
dvar int soldQuant[months][products];		// Liczba sprzedanych
dvar int stockQuant[months][products];		// Liczba w magazynie
dvar float elapsedTime[months][machines][products];	// Czas wykorzystany na maszynach na dane produkty
dvar boolean production[machines][products];// Zmienne steruj¹ce jednoczesn¹ prac¹ maszyn

// Kryteria
	/* Ogólne wzory do implementacji jak pojawi siê wektor losowy - tak na pierwszy rzut oka
	Profit: sum(m in months, p in products) soldQuant[m][p]*price[p] - storedQuant[p]*storageCost
	Risk:	mi = sum(scenarios)/nbScenarios
			forall(t in scenarios) max( abs(mi-t));
	*/

// Ograniczenia
subject to {
  // Produkcja
	forall(mc in machines) {
	  sum(p in products) production[mc][p] <= maxMachines[mc];
	  //production[mc][1]+production[mc][2]+production[mc][3]+production[mc][4] <= maxMachines[mc];
  }
   	
 	forall(m in months, p in products, mc in machines) {
 	  producedQuant[m][p]*prodCost[mc][p]*production[mc][p] == elapsedTime[m][mc][p];
  }
  
  	forall(m in months) {
 	  sum(p in products) (
 	  	sum(mc in machines) (
 	  		elapsedTime[m][mc][p]
 	  		)
 	  	) <= nbHours;
  }
 	
  // Rynek
 	forall(m in months, p in products) {
 	  soldQuant[m][p] <= monthMax[m][p];
  }
  	
  	forall(m in months, p in products) {
 	  producedQuant[m][p] + stockQuant[m][p] == soldQuant[m][p];
  }
  
  	forall(m in months) {
  	  soldQuant[m][1]*soldQuant[m][4] >= 1 || soldQuant[m][2]*soldQuant[m][4] >= 1;
   }  	    	    
  
  // Sk³ad
  	forall(m in months, p in products) {
  	  stockQuant[m][p] <= storageMax[p];
  	  if(m == 3) {
  	  	stockQuant[m][p] >= 50;
    }  	  	
   }
}  
	

/***************** COPY *****************/

// Boundries 
subject to {
  	// client
  	amtK1_F1 >=0;
  	amtK1_F1 <= uK1_F1 * maxF1;
  	amtK1_F2 >=0;
  	amtK1_F2 <= uK1_F2 * maxF2;
  	amtK1_M2 >=0;
  	amtK1_M2 <= uK1_M2 * maxM2;
  	amtK2_F1 >=0;
  	amtK2_F1 <= uK2_F1 * maxF1;
  	amtK2_M1 >=0;
  	amtK2_M1 <= uK2_M1 * maxM1;
  	amtK2_M2 >=0;
  	amtK2_M2 <= uK2_M2 * maxM2;
  	
   	amtK1_F1 + amtK1_F2 + amtK1_M2 == 130;
  	amtK2_F1 + amtK2_M1 + amtK2_M2 == 90;
  	
  	
  	// factory
  	amtK1_F1 + amtK2_F1 + amtK2_M1 <= 150;
  	amtK1_F2 + amtK1_M2 + amtK2_M2 <= 200;
  	
  	// magazine
  	amtK2_M1 <= 110;
  	amtK1_M2 + amtK2_M2 <= 150;
  	
  	// Us  	
  	uK1_F1 + uK1_F2 + uK1_M2 <= 2;
  	uK2_F1 + uK2_M1 + uK2_M2 <= 2;
  	
  	// MPO
  	v <= MPOac;
  	v <= MPOwr;
  	
	MPOac <= uMPO * lmbAvgCost * (asAvgCost - avgCost);
    MPOac <= uMPO * beta * lmbAvgCost * (asAvgCost - avgCost);
    
	MPOwr <= uMPO * lmbWhlRisk * (asWhlRisk - whlRisk);
	MPOwr <= uMPO * beta * lmbWhlRisk * (asWhlRisk - whlRisk);
};



 

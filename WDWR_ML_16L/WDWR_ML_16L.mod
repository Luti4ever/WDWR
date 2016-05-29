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

// Zmienne decyzyjne
dvar int producedQuant[months][products]; 	// Liczba wyprodukowanych
dvar int soldQuant[months][products];		// Liczba sprzedanych
dvar int stockQuant[months][products];		// Liczba w magazynie
dvar float elapsedTime[months][machines][products];	// Czas wykorzystany na maszynach na dane produkty
dvar boolean production[machines][products];// Zmienne steruj¹ce jednoczesn¹ prac¹ maszyn

// Kryteria
dexpr float profit = sum(m in months, p in products) (soldQuant[m][p]*sellProfitR[1][p] - stockQuant[m][p]*storageCost);

	/* Ogólne wzory do implementacji jak pojawi siê wektor losowy - tak na pierwszy rzut oka
	Profit: sum(m in months, p in products) soldQuant[m][p]*price[p] - storedQuant[p]*storageCost
	Risk:	mi = sum(scenarios)/nbScenarios
			forall(t in scenarios) max( abs(mi-t));
	*/

// Funkcja celu
maximize profit;

// Ograniczenia
subject to {
  
  
  // Wiêksze ni¿ 0
  forall(m in months, mc in machines, p in products) {
    elapsedTime[m][mc][p] >= 0;
    producedQuant[m][p] >= 0;
    soldQuant[m][p] >= 0;
    stockQuant[m][p] >= 0;
  }    
  /*
  // Produkcja
  
	forall(mc in machines) {
	  sum(p in products) production[mc][p] <= maxMachines[mc];
	  //production[mc][1]+production[mc][2]+production[mc][3]+production[mc][4] <= maxMachines[mc];
  }
   	*/
 	forall(m in months, p in products, mc in machines) {
 	  elapsedTime[m][mc][p] == producedQuant[m][p]*prodCost[mc][p];//*production[mc][p];
  }
  
  	forall(m in months, mc in products, p in products) {
 	  elapsedTime[m][mc][p] <= nbHours;
  }
	
  // Rynek
 	forall(m in months, p in products) {
 	  soldQuant[m][p] <= monthMax[m][p];
  }
  	
  	forall(m in months, p in products) {
 	  soldQuant[m][p] == producedQuant[m][p]; //+ stockQuant[m][p];
  }
  
  /*
  	forall(m in months) {
  	  soldQuant[m][1]*soldQuant[m][4] >= 1; // || soldQuant[m][2]*soldQuant[m][4] >= 1;
   }  	    	    
  */
  // Sk³ad
  	forall(m in months, p in products) {
  	  stockQuant[m][p] <= storageMax[p];
  	  if(m == 3) {
  	  	stockQuant[m][p] >= 50;
    }  	  	
   }
  
}

/*
main {
  /*
    var fileWyniki = new IloOplOutputFile();
	fileWyniki.open("wyniki.csv");

    var fileKosztyPerScenariusz = new IloOplOutputFile();
    fileKosztyPerScenariusz.open("KosztyPerScenariusz.csv");
*/
  	///////////////////////////////////////////////////////////////////////////////////////
  	// wyznaczenie utopii i nadiru
  	///////////////////////////////////////////////////////////////////////////////////////
/*
	var configMinKoszt = new IloOplRunConfiguration(
			"utopia_Koszt.mod",
			"parametry_zadania.dat",
			"scenariusze.dat");
	/*		
 	var modelMinKoszt = new IloOplModel (configMinKoszt.oplModel.modelDefinition, cplex);
 	modelMinKoszt.addDataSource(configMinKoszt.oplModel.dataElements)

	
 	//configMinKoszt.oplModel;
  	
  	var testConfig = new IloOplRunConfiguration(
			"WDWR_ML_16L.mod",
			"WDWR_ML_16L.dat");
			
  	var testModel = new IloOplModel (testConfig.oplModel.modelDefinition, cplex);
  	testModel.addDataSource(testConfig.oplModel.dataElements);
  	
   	testConfig.oplModel;
   	testModel.generate();
  	cplex.solve();
}

*/
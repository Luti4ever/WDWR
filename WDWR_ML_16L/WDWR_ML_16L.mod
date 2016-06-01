/*********************************************
 * OPL  Model
 * Author: Micha³ Lutoborski
 * Creation Date: 26-05-2016 at 19:41:49
 *********************************************/
// Wczytanie zmiennej steruj¹cej procesem
int calMPO = ...;
int calFSD = ...;

// Wczytywanie parametrów
int nbMachines = ...;
int nbMonths = ...;
int nbProducts = ...;

int distrColNb = ...;
int distrRowNb = ...;

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

// MPO
float asAvgProfit = ...;
float utAvgProfit = ...;
float ndAvgProfit = ...;
float lmbAvgProfit = 1/(utAvgProfit - ndAvgProfit);

float asMaxRisk = ...;
float utMaxRisk = ...;
float ndMaxRisk = ...;
float lmbMaxRisk = 1/(ndMaxRisk - utMaxRisk); // Dla ryzyka utopia <= nadiru, wiêc odwracamy znaki, ¿eby lambda > 0

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

/* Usun¹æ komentarz dla wartoœci zmiennych steruj¹cych:
calMPO = 0 oraz calFSD = 0;
Cel s³u¿y do wyznaczenia wartoœci utopii i nadiru dla indywidualnych kryteriów
*/
// dexpr float objective = avgProfit;

/* Usun¹æ komentarz dla wartoœci zmiennych steruj¹cych:
calMPO != 0 lub calFSD != 0;
Cel s³u¿y do wyznaczenia zbioru rozwi¹zañ efektywnych za pomoc¹ MPO
*/
dexpr float objective = z + epsilon*(mpoAvgProfit + mpoMaxRisk);

// Funkcja celu
maximize objective;

// Ograniczenia
subject to {
  // Wiêksze ni¿ 0
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
 	  elapsedTime[m][mc][p] <= maxMachines[mc]*nbHours;
  }
	
  // Rynek
 	forall(m in months, p in products) {
 	  soldQuant[m][p] <= monthMax[m][p];
  }
  	
  	forall(m in months, p in products) {
  	  if(m == 1) {
  	   soldQuant[m][p] <= producedQuant[m][p];
     }
     else {
       soldQuant[m][p] <= producedQuant[m][p] + stockQuant[m-1][p];
     }
  }
  
    /* Warunek sprzedawania produktów P4 w miesi¹cach w których sprzedawany jest P1 lub P2 mo¿na rozumieæ dwojako.
    Je¿eli mamy sprzedawaæ P4 jednoczeœnie z produktem P1 lub P2, to warunek jest prosty: suma sprzedanych P1 i P2 w danym miesi¹cu
    musi byæ równa sprzedanej P4. - warunek jest aktualnie zakodowany w skrypcie poni¿ej tego komentarza, przetestowany i dzia³a.
    W przypadku gdy iloœci nie musz¹ siê pokrywaæ problem jest do rozwi¹zania.
    Wprowadziæ poprawkê po konsultacjach z prowadz¹cym.
    */
  	
  	forall(m in months) {
  	  soldQuant[m][4] >= soldQuant[m][1];
  	  soldQuant[m][4] >= soldQuant[m][2];
   }
  
  // Sk³ad
  	forall(m in months, p in products) {
  	  stockQuant[m][p] <= storageMax[p];
  	  if(m == 3) {
  	  	stockQuant[m][p] >= 50;
    }  	  	
   }
   
   forall(m in months, p in products) {
  	  stockQuant[m][p] == producedQuant[m][p] - soldQuant[m][p];
   }
   
   // MPO
   z <= mpoAvgProfit;
   z <= mpoMaxRisk;
   
   mpoAvgProfit <= beta * lmbAvgProfit * (avgProfit - asAvgProfit);
   mpoAvgProfit <= lmbAvgProfit * (avgProfit - asAvgProfit);
   
   mpoMaxRisk <= beta * lmbMaxRisk * (asMaxRisk - maxRisk);
   mpoMaxRisk <= lmbMaxRisk * (asMaxRisk - maxRisk);   
}

main {
   var file = new IloOplOutputFile("wyniki.txt");
   var fileAP = new IloOplOutputFile("avgProfitScenario.txt");
   var fileMR = new IloOplOutputFile("maxRiskScenario.txt");
   
   var mod  = thisOplModel;
   var def  = mod.modelDefinition;
   var data = mod.dataElements;
   var maxAvgProfit = 19500;	// 20000
   var maxMaxRisk = 6365.8;		// 4800
   var i = 1;
  
   
   if(data.calMPO == 1 && data.calFSD == 0) {
     file.writeln("asAvgProfit;avgProfit;asMaxRisk;maxRisk;objective;m1_prod_P1;m1_prod_P2;m1_prod_P3;m1_prod_P4;m2_prod_P1;m2_prod_P2;m2_prod_P3;m2_prod_P4;m3_prod_P1;m3_prod_P2;m3_prod_P3;m3_prod_P4;m1_stock_P1;m1_stock_P2;m1_stock_P3;m1_stock_P4;m2_stock_P1;m2_stock_P2;m2_stock_P3;m2_stock_P4;m3_stock_P1;m3_stock_P2;m3_stock_P3;m3_stock_P4");
   
	 data.asMaxRisk = 0;
    
   	 while (data.asMaxRisk <= maxMaxRisk)	{
     	data.asAvgProfit = -1450;
     
     	while (data.asAvgProfit <= maxAvgProfit) {
       		mod = new IloOplModel (def, cplex);
       		mod.addDataSource(data);
       		mod.generate();
       
       		cplex.solve();
       		file.writeln(data.asAvgProfit,";",mod.avgProfit,";",data.asMaxRisk,";",mod.maxRisk,";",cplex.getObjValue(),";",mod.producedQuant[1][1],";",mod.producedQuant[1][2],";",mod.producedQuant[1][3],";",mod.producedQuant[1][4], ";",mod.producedQuant[2][1],";",mod.producedQuant[2][2],";",mod.producedQuant[2][3],";",mod.producedQuant[2][4],";",mod.producedQuant[3][1],";",mod.producedQuant[3][2], ";",mod.producedQuant[3][3],";",mod.producedQuant[3][4],";",mod.stockQuant[1][1],";",mod.stockQuant[1][2],";",mod.stockQuant[1][3],";",mod.stockQuant[1][4], ";",mod.stockQuant[2][1],";",mod.stockQuant[2][2],";",mod.stockQuant[2][3],";",mod.stockQuant[2][4],";",mod.stockQuant[3][1],";",mod.stockQuant[3][2], ";",mod.stockQuant[3][3],";",mod.stockQuant[3][4]);
       		writeln(i);
       		mod.end();
       		data.asAvgProfit = data.asAvgProfit + 2095;
       		i = i+1;
     	};
     
     	data.asMaxRisk = data.asMaxRisk + 636.58;
   	};
   }
   else if (data.calMPO == 1 && data.calFSD == 1) {
     fileAP.writeln("asAvgProfit;avgProfit;asMaxRisk;maxRisk;objective;m1_prod_P1;m1_prod_P2;m1_prod_P3;m1_prod_P4;m2_prod_P1;m2_prod_P2;m2_prod_P3;m2_prod_P4;m3_prod_P1;m3_prod_P2;m3_prod_P3;m3_prod_P4;m1_stock_P1;m1_stock_P2;m1_stock_P3;m1_stock_P4;m2_stock_P1;m2_stock_P2;m2_stock_P3;m2_stock_P4;m3_stock_P1;m3_stock_P2;m3_stock_P3;m3_stock_P4");
   	 fileMR.writeln("asAvgProfit;avgProfit;asMaxRisk;maxRisk;objective;m1_prod_P1;m1_prod_P2;m1_prod_P3;m1_prod_P4;m2_prod_P1;m2_prod_P2;m2_prod_P3;m2_prod_P4;m3_prod_P1;m3_prod_P2;m3_prod_P3;m3_prod_P4;m1_stock_P1;m1_stock_P2;m1_stock_P3;m1_stock_P4;m2_stock_P1;m2_stock_P2;m2_stock_P3;m2_stock_P4;m3_stock_P1;m3_stock_P2;m3_stock_P3;m3_stock_P4");

   	 data.asMaxRisk = 5167.13;					// Pierwsze wybrane rozwi¹zanie efektywne
   	 data.asAvgProfit = 17232.3;

     mod = new IloOplModel (def, cplex);
   	 mod.addDataSource(data);
   	 mod.generate();
   	 
   	 writeln("Analiza pierwszego rozwi¹zania...");

   	 cplex.solve();
     fileAP.writeln(data.asAvgProfit,";",mod.avgProfit,";",data.asMaxRisk,";",mod.maxRisk,";",cplex.getObjValue(),";",mod.producedQuant[1][1],";",mod.producedQuant[1][2],";",mod.producedQuant[1][3],";",mod.producedQuant[1][4], ";",mod.producedQuant[2][1],";",mod.producedQuant[2][2],";",mod.producedQuant[2][3],";",mod.producedQuant[2][4],";",mod.producedQuant[3][1],";",mod.producedQuant[3][2], ";",mod.producedQuant[3][3],";",mod.producedQuant[3][4],";",mod.stockQuant[1][1],";",mod.stockQuant[1][2],";",mod.stockQuant[1][3],";",mod.stockQuant[1][4], ";",mod.stockQuant[2][1],";",mod.stockQuant[2][2],";",mod.stockQuant[2][3],";",mod.stockQuant[2][4],";",mod.stockQuant[3][1],";",mod.stockQuant[3][2], ";",mod.stockQuant[3][3],";",mod.stockQuant[3][4]);
     fileMR.writeln(data.asAvgProfit,";",mod.avgProfit,";",data.asMaxRisk,";",mod.maxRisk,";",cplex.getObjValue(),";",mod.producedQuant[1][1],";",mod.producedQuant[1][2],";",mod.producedQuant[1][3],";",mod.producedQuant[1][4], ";",mod.producedQuant[2][1],";",mod.producedQuant[2][2],";",mod.producedQuant[2][3],";",mod.producedQuant[2][4],";",mod.producedQuant[3][1],";",mod.producedQuant[3][2], ";",mod.producedQuant[3][3],";",mod.producedQuant[3][4],";",mod.stockQuant[1][1],";",mod.stockQuant[1][2],";",mod.stockQuant[1][3],";",mod.stockQuant[1][4], ";",mod.stockQuant[2][1],";",mod.stockQuant[2][2],";",mod.stockQuant[2][3],";",mod.stockQuant[2][4],";",mod.stockQuant[3][1],";",mod.stockQuant[3][2], ";",mod.stockQuant[3][3],";",mod.stockQuant[3][4]);

     i = 1;

     fileAP.writeln("Profit: ");
     while (i<=data.distrRowNb) {
       fileAP.writeln(mod.profit[i],";");
       i++;
	 };

     i = 1;

     fileMR.writeln("Risk: ");
     while (i<=data.distrRowNb) {
       fileMR.writeln(mod.risk[i],";");
       i++;
     };
     
     data.asMaxRisk = 2340.25;						// Drugie wybrane rozwi¹zanie efektywne
   	 data.asAvgProfit = 11836.3;

     mod = new IloOplModel (def, cplex);
   	 mod.addDataSource(data);
   	 mod.generate();
   	 
   	 writeln("Analiza drugiego rozwi¹zania...");

   	 cplex.solve();
     fileAP.writeln(data.asAvgProfit,";",mod.avgProfit,";",data.asMaxRisk,";",mod.maxRisk,";",cplex.getObjValue(),";",mod.producedQuant[1][1],";",mod.producedQuant[1][2],";",mod.producedQuant[1][3],";",mod.producedQuant[1][4], ";",mod.producedQuant[2][1],";",mod.producedQuant[2][2],";",mod.producedQuant[2][3],";",mod.producedQuant[2][4],";",mod.producedQuant[3][1],";",mod.producedQuant[3][2], ";",mod.producedQuant[3][3],";",mod.producedQuant[3][4],";",mod.stockQuant[1][1],";",mod.stockQuant[1][2],";",mod.stockQuant[1][3],";",mod.stockQuant[1][4], ";",mod.stockQuant[2][1],";",mod.stockQuant[2][2],";",mod.stockQuant[2][3],";",mod.stockQuant[2][4],";",mod.stockQuant[3][1],";",mod.stockQuant[3][2], ";",mod.stockQuant[3][3],";",mod.stockQuant[3][4]);
     fileMR.writeln(data.asAvgProfit,";",mod.avgProfit,";",data.asMaxRisk,";",mod.maxRisk,";",cplex.getObjValue(),";",mod.producedQuant[1][1],";",mod.producedQuant[1][2],";",mod.producedQuant[1][3],";",mod.producedQuant[1][4], ";",mod.producedQuant[2][1],";",mod.producedQuant[2][2],";",mod.producedQuant[2][3],";",mod.producedQuant[2][4],";",mod.producedQuant[3][1],";",mod.producedQuant[3][2], ";",mod.producedQuant[3][3],";",mod.producedQuant[3][4],";",mod.stockQuant[1][1],";",mod.stockQuant[1][2],";",mod.stockQuant[1][3],";",mod.stockQuant[1][4], ";",mod.stockQuant[2][1],";",mod.stockQuant[2][2],";",mod.stockQuant[2][3],";",mod.stockQuant[2][4],";",mod.stockQuant[3][1],";",mod.stockQuant[3][2], ";",mod.stockQuant[3][3],";",mod.stockQuant[3][4]);

     i = 1;

     fileAP.writeln("Profit: ");
     while (i<=data.distrRowNb) {
       fileAP.writeln(mod.profit[i],";");
       i++;
	 };

     i = 1;

     fileMR.writeln("Risk: ");
     while (i<=data.distrRowNb) {
       fileMR.writeln(mod.risk[i],";");
       i++;
     };
     
   	 data.asMaxRisk = 850.311;						// Trzecie wybrane rozwi¹zanie efektywne
   	 data.asAvgProfit = 5239.47;

     mod = new IloOplModel (def, cplex);
   	 mod.addDataSource(data);
   	 mod.generate();
   	 
   	 writeln("Analiza trzeciego rozwi¹zania...");

   	 cplex.solve();
     fileAP.writeln(data.asAvgProfit,";",mod.avgProfit,";",data.asMaxRisk,";",mod.maxRisk,";",cplex.getObjValue(),";",mod.producedQuant[1][1],";",mod.producedQuant[1][2],";",mod.producedQuant[1][3],";",mod.producedQuant[1][4], ";",mod.producedQuant[2][1],";",mod.producedQuant[2][2],";",mod.producedQuant[2][3],";",mod.producedQuant[2][4],";",mod.producedQuant[3][1],";",mod.producedQuant[3][2], ";",mod.producedQuant[3][3],";",mod.producedQuant[3][4],";",mod.stockQuant[1][1],";",mod.stockQuant[1][2],";",mod.stockQuant[1][3],";",mod.stockQuant[1][4], ";",mod.stockQuant[2][1],";",mod.stockQuant[2][2],";",mod.stockQuant[2][3],";",mod.stockQuant[2][4],";",mod.stockQuant[3][1],";",mod.stockQuant[3][2], ";",mod.stockQuant[3][3],";",mod.stockQuant[3][4]);
     fileMR.writeln(data.asAvgProfit,";",mod.avgProfit,";",data.asMaxRisk,";",mod.maxRisk,";",cplex.getObjValue(),";",mod.producedQuant[1][1],";",mod.producedQuant[1][2],";",mod.producedQuant[1][3],";",mod.producedQuant[1][4], ";",mod.producedQuant[2][1],";",mod.producedQuant[2][2],";",mod.producedQuant[2][3],";",mod.producedQuant[2][4],";",mod.producedQuant[3][1],";",mod.producedQuant[3][2], ";",mod.producedQuant[3][3],";",mod.producedQuant[3][4],";",mod.stockQuant[1][1],";",mod.stockQuant[1][2],";",mod.stockQuant[1][3],";",mod.stockQuant[1][4], ";",mod.stockQuant[2][1],";",mod.stockQuant[2][2],";",mod.stockQuant[2][3],";",mod.stockQuant[2][4],";",mod.stockQuant[3][1],";",mod.stockQuant[3][2], ";",mod.stockQuant[3][3],";",mod.stockQuant[3][4]);

     i = 1;

     fileAP.writeln("Profit: ");
     while (i<=data.distrRowNb) {
       fileAP.writeln(mod.profit[i],";");
       i++;
	 };

     i = 1;

     fileMR.writeln("Risk: ");
     while (i<=data.distrRowNb) {
       fileMR.writeln(mod.risk[i],";");
       i++;
     };


   }     
   else {
     mod.generate();
     cplex.solve();
   }
   
   file.close();
   fileAP.close();
   fileMR.close();
}
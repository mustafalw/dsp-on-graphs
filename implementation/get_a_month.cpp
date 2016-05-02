#include<iostream>
#include<string>
#include<fstream>
using namespace std;

int main(int argc, char* argv[]){

	string line;
	string dummy;
	//ifstream in1("/alltime/"+filename, ifstream::in);
	//ofstream out1("jan2000"+filename, ofstream::out);
	
	for(int i = 0; i < 1826; i++) getline(cin, line);
	for(int i = 0; i < 31; i++){
		cin >> dummy >> dummy >> dummy >> line;
		cout << line << endl;
	}

	//in1.close();
	//out1.close();
	
}


# WRITING TESTABLE CODE FOR ABAP  - OpenSAP course
## W5- TDD : Dependency Lookup (injection) 

Software
* Cash Machine: 
    * Code Injection - deependency lookup
* SHOP - buy cart 
    * Isolate code: (emailC and FM)
    * Spy method

## notes: 
* Why the name? 
The code only knows the interface and it looks the dependency up using the factory like a phone book directory.
* CREATE PRIVATE = factory is static  (no instances)
* CL_xxx Class  // th_xxx Test Helper


## Exercise 5 - Dependency Lookup
![Pic1](https://github.com/davidvela/OS_WritingTestableABAPc/blob/master/week5/exercise5.JPG)

## Exercise 6 - Multilevel Tests
![Pic2](https://github.com/davidvela/OS_WritingTestableABAPc/blob/master/week5/exercise6.JPG)

#ifndef dep_selector_to_gecode_interface_h
#define dep_selector_to_gecode_interface_h

// Conceptual Api
#ifdef __cplusplus
extern "C" {
#endif __cplusplus

#ifdef __cplusplus
  class VersionProblem;
#else
  typedef struct VersionProblem VersionProblem;
#endif

  VersionProblem * VersionProblemCreate(int packageCount);
  void VersionProblemDestroy(VersionProblem * vp);


  int VersionProblemSize(VersionProblem *p);
  int VersionProblemPackageCount(VersionProblem *p);

  // Return ID #
  int AddPackage(VersionProblem *problem, int min, int max, int currentVersion);
  // Add constraint for package pkg @ version, 
  // that dependentPackage is at version [minDependentVersion,maxDependentVersion]
  // Returns false if system becomes insoluble.
  bool AddVersionConstraint(VersionProblem *problem, int packageId, int version, 
			    int dependentPackageId, int minDependentVersion, int maxDependentVersion);

  int GetPackageVersion(VersionProblem *problem, int packageId);
  int GetAFC(VersionProblem *problem, int packageId);
  int GetMax(VersionProblem *problem, int packageId);
  int GetMin(VersionProblem *problem, int packageId);

  void VersionProblemDump(VersionProblem * problem);
  void VersionProblemPrintPackageVar(VersionProblem * problem, int packageId);

  VersionProblem * Solve(VersionProblem * problem);

#ifdef __cplusplus
}
#endif __cplusplus

#endif // dep_selector_to_gecode_interface_h
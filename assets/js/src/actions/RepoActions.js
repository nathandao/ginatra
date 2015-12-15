import control from "control";

class RepoActions {

  updatePulseData(pulseData) {
    return pulseData;
  }

  switchVisibility(repoId, isVisible = true) {
    return { repoId, isVisible };
  }
}

export default control.createActions(RepoActions);

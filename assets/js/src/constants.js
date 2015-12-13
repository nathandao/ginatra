var baseUrl = "http://localhost:8080/";

if (process.env.NODE_ENV === "production") {
  baseUrl = "/";
}

export default {
  // API parameter constants
  REPO_PULSE_DAYS: 14,

  // End points.
  API_REPO_LIST: baseUrl + "stat/repo_list",
  API_CHART_REPO_PULSE: baseUrl + "stat/chart/timeline/commits"
};

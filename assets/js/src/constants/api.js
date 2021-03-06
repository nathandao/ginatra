let baseUrl = 'http://localhost:8080';

if (process.env.NODE_ENV === 'production') {
  baseUrl = '';
}

export const API_REPO_LIST = `${baseUrl}/stat/repo_list`;
export const API_CHART_TIMELINE_COMMITS = `${baseUrl}/stat/chart/timeline/commits`;
export const API_COMMITS_OVERVIEW = `${baseUrl}/stat/commits_overview`;
export const API_REPO_OVERVIEW = `${baseUrl}/stat/repo_overview`;
export const API_COMMITS = `${baseUrl}/stat/commits`;
export const API_AUTHORS = `${baseUrl}/stat/authors`;
export const API_HOURS = `${baseUrl}/stat/hours`;

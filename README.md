# Airbnb Analytics

## Data Source
**[Inside Airbnb](http://insideairbnb.com/get-the-data/)**

## Project Background
The goal of this project is to identify Airbnb hosts in the Portland, Oregon area that could be in need of a new home cleaning service for their accomodations. To deliver a prospective list of hosts, I loaded listing and review data from Inside Airbnb into SQL. To determine which hosts could use a new cleaning service, I wanted to sum up the number of "dirty" reviews that each host had. To determine what a dirty review is, I looked at reviews from the last two years and looked for the mention of certain keywords/phrases, such as: 
  - dirty
  - unclean
  - filthy
  - messy
  - not clean 
  - stain

After cleaning and joining the listing and review data in SQL, I put together an interactive dashboard in Tableau that lists out all of the potential hosts to contact and gives the user the ability to click into each host's Airbnb profile to learn more. The list sorts hosts by the number of dirty reviews to ensure that the top prospects are the most visible.
  
## Tableau Dashboard
**[Link to Tableau Dashboard](https://public.tableau.com/app/profile/r.prabhu/viz/AirbnbsInNeedofCleaning/AirbnbHosts)**

![image](https://user-images.githubusercontent.com/100224330/213900484-46518267-8e1a-45ff-a34d-7ac1e007a333.png)


# Advanced Continuous Monitoring System for Real-Time Performance Analytics in Linux Environment

The **Advanced Continuous Monitoring System** is a real-time monitoring tool designed for Linux environments, aimed at providing comprehensive insights into both system and container metrics. Built with open-source technologies, this tool captures, stores, and visualizes essential performance data, enabling proactive monitoring and resource optimization for DevOps environments. Utilizing **SAR** for Linux metrics, **InfluxDB** for time-series data storage, and **Grafana** for visualization, the system efficiently monitors CPU,
memory, network, and IO metrics, as well as docker container performance. The tool’s comprehensive dashboard offers **fine-grained insights** into system health and resource utilization, facilitating proactive performance optimization and streamlined troubleshooting.


## Authors

- Anjali J Kumar [@kumaranjalij](https://github.com/kumaranjalij)
- Swadi Korattiparambil [@kswadi](https://github.com/kswadi)


## File Structure

```bash
Real-Time Performance Monitoring System for Linux Environments/
├── Collect Metrics/
|   ├── collect_docker.sh
│   ├── collect_memory.sh
│   └── .........
└── automate_metrics_pipeline.sh

```

**Collect Metrics/:** Folder contains data collection scripts.

**automate_metrics_pipeline.sh:** Automates the process of starting InfluxDB and Grafana servers, running data collection scripts, and visualizing in Grafana dashboard.
## Tech Stack

**Operating System:** Linux 

**Data Collection:** SAR (System Activity Report), Docker commands 

**Database:** InfluxDB (time-series data storage)

**Visualization:** Grafana (for real-time dashboards) 

**Languages:** Shell scripting (Bash) 


## Deployment

### Prerequisites
- **Linux OS** with sar command available for system metrics.
- **InfluxDB:** Follow the installation guide [here](https://docs.influxdata.com/influxdb/v1/introduction/install/).
- **Grafana:** Follow the installation guide [here](https://grafana.com/docs/grafana/latest/setup-grafana/installation/). 


### Usage

**1. Clone the repository**

```bash
  git clone https://github.com/your-username/Advanced-Continuous-Monitoring-System.git
  cd Advanced-Continuous-Monitoring-System

```
**2. Configure Database Settings:** Update common_functions.sh with your InfluxDB connection details if different from the defaults.

**3. Run the Automated Pipeline:** Execute the automate_metrics_pipeline.sh file, which automates the entire setup process: 
- Starts InfluxDB and Grafana servers.
- Runs data collection scripts to gather system and Docker metrics.
- Pushes data to InfluxDB for storage.
- Opens Grafana to display real-time visualizations.

```
 ./automate_metrics_pipeline.sh
```
## Documentation

[Documentation](https://linktodocumentation)


## Screenshots

![App Screenshot](https://via.placeholder.com/468x300?text=App+Screenshot+Here)


## Contributing

Contributions are welcome! If you'd like to help improve the project, please fork the repository, make your changes, and submit a pull request. For major changes, please open an issue first to discuss what you would like to change.

### Steps to Contribute

**1. Fork the Repository**   

Click on the "Fork" button at the top right of this page to create a personal copy of the repository.

**2. Clone Your Forked Repository**  
```
git clone https://github.com/your-username/Advanced-Continuous-Monitoring-System.git
cd Advanced-Continuous-Monitoring-System
```

**3. Create a New Branch**  

For each contribution, create a new branch with a descriptive name. This keeps changes organized:
```
git checkout -b feature/your-feature-name
```

**4. Make Your Changes**  
- Implement your changes, add new features, or fix bugs.
- Follow coding standards and include comments for clarity.

**5. Commit and Push Your Changes**  

Stage and commit your changes with a clear commit message. Push your branch to your forked repository:
```
git add .
git commit -m "Add feature: Description of your feature"
git push origin feature/your-feature-name
```

**6. Open a Pull Request (PR)**  
- Go to your forked repository on GitHub.
- Click on the "Compare & pull request" button.
- Write a detailed description of your changes, referencing any related issues.
- Submit the PR to the main branch of the original repository.

**7. Work with the Review**  

Be prepared to discuss and refine your changes if maintainers request modifications.
Respond to comments and make updates as needed.

**8. Celebrate 🎉**  

Once your PR is approved and merged, you’ve successfully contributed to the project!


### Contribution Guidelines

- Ensure that code is well-documented and follows the repository’s style.
- Write clear and concise commit messages.
- If adding new features, update the README as necessary to document usage.

By contributing to this project, you agree that your contributions will be licensed under the same GPL v3 license that covers the project.

## License

This project is licensed under the GNU General Public License (GPL) v3. See the [LICENSE](https://github.com/kumaranjalij/Advanced-Continuous-Monitoring-System/blob/main/LICENSE) file for more details


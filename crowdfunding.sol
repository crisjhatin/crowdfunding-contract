// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Crowdfunding {

    enum State {Open, Closed} 

    struct Contribution {
        address contributor;
        uint value;
    }

    struct Project{
        string id;
        string name;
        string description;
        address payable author;
        State state;
        uint funds;
        uint fundraisingGoal;
    }

    //Array de proyectos
    Project[] public projects;
    mapping(string => Contribution[]) public contributions;

    event FundProject(string id, uint value);

    event ChangeProjectState(State newState);

    event ProjectCreated(string id, string name, string description, uint fundraisingGoal);

    modifier onlyOwner(uint projectIndex) {
        require(msg.sender == projects[projectIndex].author, "No eres el owner");
        _;
    }

    modifier projectFunders(uint projectIndex) {
        require(msg.sender != projects[projectIndex].author , "No puedes colaborar a tu propio proyecto");
        _;
    }

    error StateError(State state, string message);

    error ValueOrStateNotValid(uint unit, State state);

    function createProject(string calldata id, string calldata name, string calldata description, uint fundraisingGoal) public {
        require(fundraisingGoal>0, "fundraising goal must be greater than 0");
        Project memory project=Project(id, name, description, payable(msg.sender), State.Open, 0, fundraisingGoal);
        projects.push(project);
        emit ProjectCreated(id, name, description, fundraisingGoal);
    }


    //Todos pueden colaborar excepto el owner 
    function fundProject(uint projectIndex) public payable projectFunders(projectIndex) {
        //Encerrando en variable "project" tipo Project, el proyecto que se va a fondear.
        Project memory project =projects[projectIndex];
        if(msg.value>0 && project.state==State.Open){
            project.author.transfer(msg.value);
            project.funds += msg.value;
            projects[projectIndex]=project;

            //Añadiendo contribución a mapping "contributions"
            contributions[project.id].push(Contribution(msg.sender, msg.value));

            emit FundProject(project.id, msg.value);
        }
        else{
            revert ValueOrStateNotValid(msg.value, project.state);
        }
    }
    
    //Solo el dueño puede cambiar el estado
    function changeProjectState(State newState, uint projectIndex) public onlyOwner(projectIndex) {
         Project memory project =projects[projectIndex];
        if(newState!=project.state){
            project.state=newState;
            projects[projectIndex]=project;
            emit ChangeProjectState(newState);
        }
        else{
            revert StateError(newState, "You cannot rewrite the same state");
        }
    }

}
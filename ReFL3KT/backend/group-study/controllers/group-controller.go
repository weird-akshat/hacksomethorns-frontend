package controllers

import (
	"gs-api/config"
	"gs-api/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

// Create new group with goal and task
func CreateGroup(c *gin.Context) {
	var request struct {
		GoalName string `json:"goal_name" binding:"required"`
		TaskName string `json:"task_name" binding:"required"`
		UserID   int    `json:"user_id" binding:"required"`
		UserName string `json:"user_name" binding:"required"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Generate unique group code
	groupCode, err := models.GenerateGroupCode()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate group code"})
		return
	}

	// Create goal and task (assuming they don't exist)
	goal := models.Goal{Name: request.GoalName}
	config.DB.Create(&goal)

	task := models.Task{Name: request.TaskName, GoalID: goal.ID}
	config.DB.Create(&task)

	// Create group study entry
	groupStudy := models.GroupStudy{
		GroupCode:      groupCode,
		GoalID:         goal.ID,
		TaskID:         task.ID,
		UserID:         request.UserID,
		GoalName:       request.GoalName,
		TaskName:       request.TaskName,
		UserName:       request.UserName,
		GoalCompletion: 0.0,
	}

	result := config.DB.Create(&groupStudy)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create group"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"group_code": groupCode,
		"message":    "Group created successfully",
		"data":       groupStudy,
	})
}

// Join existing group
func JoinGroup(c *gin.Context) {
	var request struct {
		GroupCode int64  `json:"group_code" binding:"required"`
		UserID    int    `json:"user_id" binding:"required"`
		UserName  string `json:"user_name" binding:"required"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Find existing group to get goal and task info
	var existingGroup models.GroupStudy
	result := config.DB.First(&existingGroup, "group_code = ?", request.GroupCode)
	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Group not found"})
		return
	}

	// Create new entry for user in the same group
	newMember := models.GroupStudy{
		GroupCode:      request.GroupCode,
		GoalID:         existingGroup.GoalID,
		TaskID:         existingGroup.TaskID,
		UserID:         request.UserID,
		GoalName:       existingGroup.GoalName,
		TaskName:       existingGroup.TaskName,
		UserName:       request.UserName,
		GoalCompletion: 0.0,
	}

	result = config.DB.Create(&newMember)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to join group"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Successfully joined group",
		"data":    newMember,
	})
}

// Leave group
func LeaveGroup(c *gin.Context) {
	groupCode := c.Param("groupCode")
	userID := c.Param("userID")

	result := config.DB.Delete(&models.GroupStudy{}, "group_code = ? AND user_id = ?", groupCode, userID)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to leave group"})
		return
	}

	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found in group"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Successfully left group"})
}

// Get user progress
func GetUserProgress(c *gin.Context) {
	groupCode := c.Param("groupCode")
	userID := c.Param("userID")

	var progress models.GroupStudy
	result := config.DB.First(&progress, "group_code = ? AND user_id = ?", groupCode, userID)
	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User progress not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": progress})
}

// Update user progress
func UpdateProgress(c *gin.Context) {
	groupCode := c.Param("groupCode")
	userID := c.Param("userID")

	var request struct {
		GoalCompletion float64 `json:"goal_completion" binding:"required,min=0,max=100"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	result := config.DB.Model(&models.GroupStudy{}).
		Where("group_code = ? AND user_id = ?", groupCode, userID).
		Update("goal_completion", request.GoalCompletion)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update progress"})
		return
	}

	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found in group"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Progress updated successfully"})
}

// Get all group members and their progress
func GetGroupProgress(c *gin.Context) {
	groupCode := c.Param("groupCode")

	var members []models.GroupStudy
	result := config.DB.Find(&members, "group_code = ?", groupCode)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch group progress"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"group_code":    groupCode,
		"members":       members,
		"total_members": len(members),
	})
}

// Add new task to existing group
func AddTaskToGroup(c *gin.Context) {
	groupCode := c.Param("groupCode")

	var request struct {
		TaskName string `json:"task_name" binding:"required"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get group info to find goal ID
	var existingGroup models.GroupStudy
	result := config.DB.First(&existingGroup, "group_code = ?", groupCode)
	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Group not found"})
		return
	}

	// Create new task
	newTask := models.Task{
		Name:   request.TaskName,
		GoalID: existingGroup.GoalID,
	}
	config.DB.Create(&newTask)

	// Get all group members
	var members []models.GroupStudy
	config.DB.Find(&members, "group_code = ?", groupCode)

	// Add new task entry for each member
	for _, member := range members {
		newTaskEntry := models.GroupStudy{
			GroupCode:      member.GroupCode,
			GoalID:         member.GoalID,
			TaskID:         newTask.ID,
			UserID:         member.UserID,
			GoalName:       member.GoalName,
			TaskName:       request.TaskName,
			UserName:       member.UserName,
			GoalCompletion: 0.0,
		}
		config.DB.Create(&newTaskEntry)
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Task added to group successfully",
		"task":    newTask,
	})
}

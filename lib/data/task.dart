enum TaskPriority { high, mid, low }

class Task {
  final int id;
  final String text;
  final bool done;
  final String? categorySlug;
  final TaskPriority priority;
  final String? timeLabel;

  const Task({
    required this.id,
    required this.text,
    required this.done,
    this.categorySlug,
    required this.priority,
    this.timeLabel,
  });

  Task copyWith({bool? done, String? categorySlug, bool clearCategorySlug = false}) => Task(
    id: id,
    text: text,
    done: done ?? this.done,
    categorySlug: clearCategorySlug ? null : (categorySlug ?? this.categorySlug),
    priority: priority,
    timeLabel: timeLabel,
  );
}

const seedTasks = [
  Task(id:1, text:'Review PR trước 11h',      done:false, categorySlug:'work',     priority:TaskPriority.high, timeLabel:'9:00'),
  Task(id:2, text:'Họp sync team lúc 2h',      done:false, categorySlug:'work',     priority:TaskPriority.mid,  timeLabel:'14:00'),
  Task(id:3, text:'Mua sữa và trứng',          done:false, categorySlug:'buy',      priority:TaskPriority.low,  timeLabel:null),
  Task(id:4, text:'Viết spec cho feature mới', done:true,  categorySlug:'work',     priority:TaskPriority.mid,  timeLabel:null),
  Task(id:5, text:'Gọi điện cho nhà',          done:false, categorySlug:'personal', priority:TaskPriority.low,  timeLabel:'20:00'),
  Task(id:6, text:'Update deck cho investor',  done:false, categorySlug:'startup',  priority:TaskPriority.high, timeLabel:null),
];

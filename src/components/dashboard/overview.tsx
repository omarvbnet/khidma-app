import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Overview as OverviewChart } from "@/components/ui/overview-chart"

interface OverviewProps {
  data: {
    date: string
    count: number
  }[]
}

export function Overview({ data }: OverviewProps) {
  return (
    <Card className="col-span-4">
      <CardHeader>
        <CardTitle>Overview</CardTitle>
      </CardHeader>
      <CardContent className="pl-2">
        <OverviewChart data={data} />
      </CardContent>
    </Card>
  )
} 